require 'test_helper'

class CosmeticFormulationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get cosmetic_formulations_index_url
    assert_response :success
  end

  test "should get new" do
    get cosmetic_formulations_new_url
    assert_response :success
  end

  test "should get create" do
    get cosmetic_formulations_create_url
    assert_response :success
  end

  test "should get show" do
    get cosmetic_formulations_show_url
    assert_response :success
  end

end
