module WaitForAjax
  def wait_for_ajax(session)
    Timeout.timeout(25) do
      loop until finished_all_ajax_requests?(session)
    end
  end

  def finished_all_ajax_requests?(session)
    session.evaluate_script('jQuery.active').zero?
  end
end
