require 'ostruct'
class User::GetSettlementContext < ::BaseContext
  def initialize(user, time = nil)
    @user = user
    @time = time
  end

  def perform
    init_time!
    OpenStruct.new(
      my_settlement: my_settlement,
      settlements: others_settlments
    )
  end

  private

  def init_time!
    @time ||= Time.now
    @time = @time.to_datetime if @time.is_a?(String)
    @start_at = @time.beginning_of_month
    @end_at = @time.end_of_month
  end

  def projects_map
    @projects_map ||= UserProjectsQuery.new(@user).query(archived: false).inject({}) { |h, p| h.merge(p.id => p) }
  end

  def projects_settlement
    @projects_settlement ||= projects_map.values.inject({}) do |h, project|
      h.merge(project.id => Project::GetSettlementContext.new(project, @time).perform)
    end
  end

  def my_settlement
    @my_settlement ||= settlements.select { |o| o.user.id == @user.id }.first
  end

  def others_settlments
    @others_settlments ||= settlements.reject { |o| o.user.id == @user.id }
  end

  def each_user
    @each_user ||= projects_settlement.inject({}) do |h, a|
      project_id = a[0]
      settlement = a[1]
      settlement.each_user.each do |user_id, user_settlement|
        h[user_id] ||= {}
        h[user_id][project_id] = user_settlement
      end
      h
    end
  end

  def settlements
    @settlements ||= each_user.map do |a|
      user_id = a[0]
      project_settlements_map = a[1]
      OpenStruct.new(
        user: users_map[user_id],
        settlements: project_settlements_map.map do |b|
          project_id = b[0]
          project_settlement = b[1]
          OpenStruct.new(
            project: projects_map[project_id],
            settlement: project_settlement
          )
        end,
        total_settlement: get_total_settelment(project_settlements_map.values)
      )
    end
  end

  def get_total_settelment(settlements_list)
    wage = get_array_max_count_value(settlements_list.map(&:wage))
    minutes = settlements_list.map(&:minutes).inject(&:+)
    income = settlements_list.map(&:income).inject(&:+)
    project_hours = (income.to_f / wage).round(2)
    hours = (minutes.to_f / 60).round(2)
    SettleValue.new(wage: wage, project_wage: nil, income: income, hours: hours, project_hours: project_hours, minutes: minutes)
  end

  def users_map
    @users_map ||= User.where(id: each_user.keys).all.inject({}) { |h, u| h.merge(u.id => u) }
  end

  def get_array_max_count_value(a)
    a.group_by{ |e| e }.inject([]) { |h, aa| h << [aa[0], aa[1].length] }.sort_by { |aa| aa[1] }.last[0]
  end
end
