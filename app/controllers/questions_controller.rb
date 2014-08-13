class QuestionsController < ApplicationController
  expose( :quiz ) { Quiz.find params[:quiz_id] if params[:quiz] }
  expose( :context ) { quiz }
  expose :q_scope do
    scope = context.questions if context
    scope ||= Question.all
    scope
  end
  expose :q do
    q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] )
  end
  expose( :questions ) { q.result.ordered.page(params[:page]) }
  expose :question_attributes do
    if params[:question]
      params.require( :question ).permit(
        :name, :content, :global, :disposition, { quiz_ids: [] } )
    else
      {}
    end
  end
  expose :question, attributes: :question_attributes
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :index,
    attribute_check: true, load_method: :question

  # POST /questions
  # POST /questions.xml
  def create
    respond_to do |format|
      if question.save
        format.html { redirect_to( question, flash: { success: 'Question created.' } ) }
        format.xml  { render xml: question, status: :created, location: question }
      else
        format.html { render action: "new" }
        format.xml  { render xml: question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    respond_to do |format|
      if question.save
        format.html { redirect_to( question, flash: { success: 'Question updated.' } ) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    question.destroy

    respond_to do |format|
      format.html { redirect_to( questions_url, flash: { success: "Question destroyed." } ) }
      format.xml  { head :ok }
    end
  end
end

