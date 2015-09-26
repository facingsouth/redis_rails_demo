class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all

    @hot_posts = Post.where(id: ordered_posts_by_num_views)

    @msg = track_unique_ip

  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @num_views = record_num_views
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :content)
    end

    # use redis ordered sets to order posts by num of views
    def ordered_posts_by_num_views
      key = "hot-posts"

      Post.all.each do |post|
        num_views = $redis.get "#{Date.today.year}:#{Date.today.month}:#{Date.today.day}:posts:#{post.id}:views"
        $redis.zadd key, num_views, post.id
      end

      $redis.zrevrange key, 0, 5
    end

    # use redis strings to track num of views on a post
    def record_num_views
      key = "#{Date.today.year}:#{Date.today.month}:#{Date.today.day}:posts:#{@post.id}:views"
      $redis.incr key
      $redis.get key
    end

    # use redis sets to track unique visitor ips
    def track_unique_ip
      visitor_ip = request.remote_ip
      key = "posts:visitor-ips"

      if $redis.sadd key, visitor_ip
        "Hello, my NEW friend from #{visitor_ip}"
      else
        "Hello, my OLD friend from #{visitor_ip}"
      end
    end
end
