require 'test_helper'

class PhysicalObjectsControllerTest < ActionController::TestCase
  setup do
    @physical_object = physical_objects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:physical_objects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create physical_object" do
    assert_difference('PhysicalObject.count') do
      post :create, physical_object: {  }
    end

    assert_redirected_to physical_object_path(assigns(:physical_object))
  end

  test "should show physical_object" do
    get :show, id: @physical_object
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @physical_object
    assert_response :success
  end

  test "should update physical_object" do
    patch :update, id: @physical_object, physical_object: {  }
    assert_redirected_to physical_object_path(assigns(:physical_object))
  end

  test "should destroy physical_object" do
    assert_difference('PhysicalObject.count', -1) do
      delete :destroy, id: @physical_object
    end

    assert_redirected_to physical_objects_path
  end
end
