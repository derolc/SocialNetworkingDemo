class FriendshipController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_friend

  # POST /add_friend
  # Sends a friend request to user
  def add_friend
    current_user.friend_request(@friend)
    redirect_to request.referrer, notice: 'Friend request sent'
  end

  # DELETE /remove_friend
  # Remove a friend from friend list
  def remove_friend
    current_user.remove_friend(@friend)
    redirect_to request.referrer, notice: 'Friend removed from list'
  end

  # POST /accept_friend
  # Accept a friend request
  def accept_friend
    current_user.accept_request(@friend)
    redirect_to request.referrer, notice: 'Friend request accepted'
  end

  # POST /reject_friend
  # Reject a friend request
  def reject_friend
    current_user.decline_request(@friend)
    redirect_to request.referrer, notice: 'Friend request declined'
  end

  private
  def set_friend
    @friend = User.find(params[:id])
  end
end
