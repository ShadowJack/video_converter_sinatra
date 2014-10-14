function delete_video(id)
{
  $.ajax(
    {
      url: '/videos/' + id,
      type: 'DELETE',
      success: function(data, status)
      {
        window.location.href = '/videos';
      }
    }
  );
}
