class QuestionsController < ApplicationController
  before_filter :initialize_context
  before_filter :new_question_from_params, only: [ :new, :create ]
  filter_resource_access
  before_filter :setup_breadcrumbs

  # GET /questions
  # GET /questions.xml
  # GET /quizzes/:quiz_id/questions
  # GET /quizzes/:quiz_id/questions.xml
  def index
    search = params[:term] ? { name_cont: params[:term] } : params[:q]
    @q ||= Question.search( search )
    @questions = @q.result.ordered
    @questions = @questions.where { |q| q.quiz_id.eq( @quiz.id ) } if @quiz
    @questions = @questions.page( params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.xml
  def create
    respond_to do |format|
      if @question.save
        flash[:notice] = 'Question was successfully created.'
        format.html { redirect_to(@question) }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    respond_to do |format|
      if @question.update_attributes(params[:question])
        flash[:notice] = 'Question was successfully updated.'
        format.html { redirect_to(@question) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question.destroy

    respond_to do |format|
      format.html { redirect_to(questions_url, notice: "Question was successfully destroyed.") }
      format.xml  { head :ok }
    end
  end

  def initialize_context
    @question = Question.find params[:id] if params[:id]
    @quiz = Quiz.find params[:quiz_id] if params[:quiz_id]
    @context = @quiz
  end

  def new_question_from_params
    @question = Question.new( params[:question] )
  end

  def setup_breadcrumbs
    if @quiz
      add_breadcrumb "Quizzes", quizzes_path
      add_breadcrumb @quiz, quiz_path( @quiz )
    end
    add_breadcrumb "Questions", polymorphic_path( [ @context, :questions ] )
    if @question && @question.persisted?
      add_breadcrumb @question, question_path( @question )
    end
  end
end

