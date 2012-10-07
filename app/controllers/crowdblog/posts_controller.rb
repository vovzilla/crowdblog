module  Crowdblog
  class PostsController < ApplicationController
    respond_to :html, :json
    cache_sweeper :post_sweeper

    before_filter :load_post, :only => [ :edit, :update, :destroy ]

    def new
      @post = Post.new
    end

    def index
      @posts = Post.scoped_for(current_user)
      respond_with @posts
    end

    def create
      @post = Post.new(post_params)
      @post.author = current_user
      @post.regenerate_permalink
      if @post.save
        respond_with @post, :location => crowdblog.posts_path
      end
    end

    def destroy
      @post.destroy
      respond_with @post, :location => crowdblog.posts_path
    end

    def show
      @post = Post.includes(:assets).find(params[:id])
      respond_to do |format|
        format.json { render json: @post.to_json(include: :assets) }
      end
    end

    def edit
    end

    def update
      @post.update_attributes(post_params, updated_by: current_user)
      if @post.allowed_to_update_permalink?
        @post.regenerate_permalink
        @post.save!
      end

      Rails.logger.info "HERE WE GO"
      @post.publish_if_allowed(post_params[:transition], current_user) if post_params[:transition]

      respond_with @post do |format|
        format.html { redirect_to crowdblog.posts_path }
      end
    end

    private
    def load_post
      @post = Post.scoped_for(current_user).find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :body, :updated_by, :ready_for_review, :transition)
    end
  end
end
