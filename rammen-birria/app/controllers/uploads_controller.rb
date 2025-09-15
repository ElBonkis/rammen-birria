class UploadsController < ApplicationController
  def direct
    blob = ActiveStorage::Blob.create_before_direct_upload!(
      filename: params[:filename],
      byte_size: params[:byte_size],
      checksum: params[:checksum],
      content_type: params[:content_type]
    )

    render json: {
      direct_upload: blob.service_url_for_direct_upload,
      signed_id: blob.signed_id,
      headers: blob.service_headers_for_direct_upload
    }
  end
end
