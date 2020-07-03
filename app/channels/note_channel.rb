class NoteChannel < ApplicationCable::Channel
  def subscribed
    @note = Block.notes.find_or_initialize_by id: params[:id]

    stream_for @note
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # TODO
  # - update existing tags
  # 
  # data:
  #   note:
  #     id
  #     title
  def update_title data
    title = data['note']['title']

    @note.update! title: title

    broadcast_to @note, { event: 'title_updated', requested_at: data['requested_at'] }

    # TODO another note with duplicate title
  end

  # data:
  #   note:
  #     id
  #     blocks:
  #       [
  #         
  #       ]
  def update_blocks data
    child_blocks = data['note']['blocks']

    child_blocks.each do |block|
      Block.create_or_update_from_doc! block, @note
    end

    @note.update! child_block_ids: child_blocks.map{|b| b['attrs']['block_id'] }

    broadcast_to @note, { event: 'blocks_updated', requested_at: data['requested_at'] }
  end
end
