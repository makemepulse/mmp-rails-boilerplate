class Ability
  include CanCan::Ability

  def initialize(user_admin)
    # Define abilities for the passed in user here. For example:
    if user_admin

        if user_admin.admin?
          can :manage, :all
        else


            c = Country.where("countries.id = ?", user_admin.country_id)

            can :access, :rails_admin
            can :dashboard
           
            #can :manage, User, User.where("country_id = ?", user_admin.country_id) do |o|
            #    true
            #end

        end
        
    end
  end
end
