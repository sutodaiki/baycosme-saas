require 'test_helper'

class Admin::FormalOrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_formal_orders_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_formal_orders_show_url
    assert_response :success
  end

  test "should get edit" do
    get admin_formal_orders_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_formal_orders_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_formal_orders_destroy_url
    assert_response :success
  end

end
