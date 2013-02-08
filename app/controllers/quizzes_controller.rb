class QuizzesController < ApplicationController
  expose( :q_scope ) { Quiz.scoped }
  expose( :q ) { q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] ) }
  expose( :quizzes ) { q_scope.result.ordered.page(params[:page]) }
  expose :quiz
  filter_resource_access

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
      format.html { redirect_to quizzes_url, flash: { success: "Quiz was successfully destroyed." } }
      format.xml  { head :ok }
    end
  end
end

