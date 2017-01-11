class UsersController < ApplicationController
  before_filter :authenticate_user!

  # GET /users
  # List all users
  def index
    @users = User.all - current_user.friends - [current_user]
  end

  # GET /friends
  # List all friends
  def friends
    @friends = current_user.friends
  end

  # GET /pending_friends
  # List all friend requests sent by me
  def pending_friends
    @friends = current_user.pending_friends
  end

  # GET /requested_friends
  # List all friend requests sent to me
  def requested_friends
    @friends = current_user.requested_friends
  end

end
