function delete_video(id)
{
  console.log("Got request to delete video ", id);
  console.log($);
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
