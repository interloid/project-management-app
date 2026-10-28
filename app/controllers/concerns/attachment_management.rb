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

  def attachment_param_key
    controller_name.singularize.to_sym
  end

  def attachment_record
    instance_variable_get("@#{attachment_param_key}")
  end

  def remove_attachments
    attachment_ids = attachment_params[:remove_attachment_ids].to_a.reject(&:blank?)
    return if attachment_ids.empty?

    attachment_record.attachments_attachments.where(id: attachment_ids).each(&:purge_later)
  end

  def attachment_params
    params.require(attachment_param_key).slice(:attachments, :remove_attachment_ids).permit(attachments: [], remove_attachment_ids: [])
  end
end
