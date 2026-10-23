module AttachmentManagement
  extend ActiveSupport::Concern

  private

  def update_attachments
    remove_attachments
    attach_new_files
  end

  def attach_new_files
    files = attachment_params[:attachments].to_a.reject(&:blank?)
    return if files.empty?

    attachment_record.attachments.attach(files)
  end

  def remove_attachments
    attachment_ids = attachment_params[:remove_attachment_ids].to_a.reject(&:blank?)
    return if attachment_ids.empty?

    attachment_record.attachments_attachments.where(id: attachment_ids).each(&:purge)
  end

  def attachment_params
    params.require(attachment_param_key).permit(attachments: [],remove_attachment_ids: [])
  end
end
