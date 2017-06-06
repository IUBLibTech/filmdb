class UserPolicy < ApplicationPolicy

	def index?
		current_user_object.can_delete?
	end

	def new?
		current_user_object.can_delete?
	end

	def create?
		current_user_object.can_delete?
	end

	def edit?
		current_user_object.can_delete?
	end

	def update?
		current_user_object.can_delete?
	end

	def show?
		current_user_object.can_delete?
	end

	def destroy?
		current_user_object.can_delete?
	end

end