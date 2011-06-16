class QuizzesController < ApplicationController
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_quiz_from_params, :only => [ :new, :create ]
  filter_resource_access
  before_filter :setup_breadcrumbs

  # GET /quizzes
  # GET /quizzes.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @quizzes }
    end
  end

  # GET /quizzes/1
  # GET /quizzes/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @quiz }
    end
  end

  # GET /quizzes/new
  # GET /quizzes/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @quiz }
    end
  end

  # GET /quizzes/1/edit
  def edit
  end

  # POST /quizzes
  # POST /quizzes.xml
  def create
    respond_to do |format|
      if @quiz.save
        flash[:notice] = 'Quiz was successfully created.'
        format.html { redirect_to(@quiz) }
        format.xml  { render :xml => @quiz, :status => :created, :location => @quiz }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @quiz.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /quizzes/1
  # PUT /quizzes/1.xml
  def update
    respond_to do |format|
      if @quiz.update_attributes(params[:quiz])
        flash[:notice] = 'Quiz was successfully updated.'
        format.html { redirect_to(@quiz) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quiz.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /quizzes/1
  # DELETE /quizzes/1.xml
  def destroy
    @quiz.destroy

    respond_to do |format|
      format.html { redirect_to(quizzes_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @quiz = Quiz.find params[:id] if params[:id]
  end

  def initialize_index
    @quizzes = Quiz.scoped
  end

  def new_quiz_from_params
    Quiz.new( params[:quiz] )
  end

  def setup_breadcrumbs
    add_breadcrumb 'Quizzes', quizzes_path
    if @quiz && @quiz.persisted?
      add_breadcrumb @quiz, quiz_path( @quiz )
    end
  end
end

