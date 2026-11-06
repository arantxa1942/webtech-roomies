require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def valid_params(overrides = {})
    { user: { full_name: "Ana Pérez", email_address: "ana@example.com",
              password: "password123", password_confirmation: "password123" }.merge(overrides) }
  end

  test "new is public" do
    get new_user_path
    assert_response :success
  end

  test "create signs the new member in" do
    assert_difference("User.count", 1) { post users_path, params: valid_params }

    assert_redirected_to root_path
    assert cookies[:session_id]
    assert User.find_by(email_address: "ana@example.com").member?
  end

  test "create ignores a role sent by the client" do
    post users_path, params: valid_params(role: "moderator")

    assert User.find_by(email_address: "ana@example.com").member?
  end

  test "create with invalid data re-renders the form" do
    assert_no_difference("User.count") do
      post users_path, params: valid_params(email_address: "not-an-email", password_confirmation: "other")
    end

    assert_response :unprocessable_entity
  end

  test "landing page and listings are public" do
    get root_path
    assert_response :success

    get listings_path
    assert_response :success
  end

  test "profile requires an account" do
    get edit_profile_path
    assert_redirected_to new_session_path
  end
end
