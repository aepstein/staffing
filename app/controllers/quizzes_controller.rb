class QuizzesController < ApplicationController
  expose( :q_scope ) { Quiz.all }
  expose( :q ) { q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] ) }
  expose( :quizzes ) { q.result.with_permissions_to(:show).ordered.page(params[:page]) }
  expose( :quiz_attributes ) do
    if params[:quiz]
      params.require(:quiz).permit( :name,
       { quiz_questions_attributes: [ :id, :_destroy, :position, :question_id ] } )
    else
      {}
    end
  end
  expose :quiz do
    quiz = if params[:id]
      Quiz.find params[:id]
    else
      Quiz.new
    end
    quiz.assign_attributes quiz_attributes
    quiz
  end
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :index,
    attribute_check: true, load_method: :quiz

  # POST /quizzes
  # POST /quizzes.xml
  def create
    respond_to do |format|
      if quiz.save
        format.html { redirect_to quiz, flash: { success: 'Quiz created.' } }
        format.xml  { render xml: quiz, status: :created, location: quiz }
      else
        format.html { render action: "new" }
        format.xml  { render xml: quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /quizzes/1
  # PUT /quizzes/1.xml
  def update
    respond_to do |format|
      if quiz.save
        format.html { redirect_to quiz, flash: { success: 'Quiz updated.' } }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quizzes/1
  # DELETE /quizzes/1.xml
  def destroy
    quiz.destroy

    respond_to do |format|
      format.html { redirect_to quizzes_url, flash: { success: "Quiz destroyed." } }
      format.xml  { head :ok }
    end
  end
end

