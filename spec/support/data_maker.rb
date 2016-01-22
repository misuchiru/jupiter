module DataMaker
  def data_for(key, attrs = {})
    send("data_for_#{key}").merge(attrs)
  end

  private

  def data_for_user
    { name: "5Fpro",
      email: "user@5fpro.com", # TODO: sequence
      password: "12341234"
    }
  end

  def data_for_category
    { name: "category haha"
    }
  end

  def data_for_creating_category
    data_for_category.merge(
      tag_list: "a,b,c"
    )
  end

  def data_for_creating_user
    data_for_user.merge(
      admin: "0"
    )
  end

  def data_for_project
    { name: "venus",
      price_of_hour: 1000,
      owner_id: FactoryGirl.create(:user).id
    }
  end

  def data_for_comment
    { user_id: FactoryGirl.create(:user).id
    }
  end

  def data_for_project_user
    { user_id: FactoryGirl.create(:user).id,
      project_id: FactoryGirl.create(:project).id
    }
  end

  def data_for_update_project
    { name: "blablabla",
      price_of_hour: 10_000_000
    }
  end

  def data_for_record
    { record_type: :coding,
      minutes: 120,
      note: "fix bug"
    }
  end

  def data_for_update_record
    { record_type: :etc,
      minutes: 10,
      note: "update minutes"
    }
  end
end
