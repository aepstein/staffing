module Auth
  class AttachmentsController < ApplicationController
    before_filter :require_user
    expose :attachment
    filter_access_to :show, load_method: :attachment, attribute_check: true

    # GET /auth/users/1
    # GET /auth/users/1.xml
    def show
      send_file attachment.document.path, disposition: 'attachment',
        filename: "#{attachment.to_s :file}"
    end
  end
end
