/*global $*/

var LOADING = '<i class="my-3 fa fa-spin fa-circle-o-notch"></i>'

function nl2br(str) {
  return str.replace(/(?:\r\n|\r|\n)/g, '<br>');
}

function br2nl(str) {
  return str.replace(/<br>/g, "\r\n");
}

$(function() {

  function ajaxCompleted() {

    $('[data-account-username]').not('#modal [data-account-username]').click(function() {
      $('#modal .modal-content').load('/u/' + $(this).attr('data-account-username'), function() {
        $('#modal').modal('show');
        $('[data-toggle="tooltip"]').tooltip('hide');
      });
    })

    $('a[data-confirm]:not([data-confirm-registered])').each(function() {
      $(this).click(function() {
        $(this).removeClass('no-trigger')

        var message = $(this).data('confirm');
        if (!confirm(message)) {
          $(this).addClass('no-trigger')
          return false
        }
      })
      $(this).attr('data-confirm-registered', 'true')
    });

    $('form.add-placeholders label[for]').each(function() {
      var input = $(this).next().children().first()
      if (!$(input).attr('placeholder'))
        $(input).attr('placeholder', $.trim($(this).text()))
    });

    $('[data-toggle="tooltip"]').tooltip({
      html: true,
      title: function() {
        if ($(this).attr('title').length > 0)
          return $(this).attr('title')
        else
          return $(this).next('span').html()
      }
    })

    $("abbr.timeago").timeago()

    $(".datepicker:not(.datepickerd)").addClass('datepickerd').datepicker({
      format: 'yyyy-mm-dd'
    });
    $(".datetimepicker:not(.flatpickrd)").addClass('flatpickrd').flatpickr({
      altInput: true,
      altFormat: 'J F Y, H:i',
      enableTime: true,
      time_24hr: true
    });

    $('[id=comment_subject], [id=comment_body]').focus(function() {
      $(this.form).find('.btn-primary').parent().parent().removeClass('d-none')
    })
    autosize($('textarea[id=comment_body]'));

    $('[id=comment_body]').each(function() {
      var tribute = new Tribute({
        values: network,
        selectTemplate: function(item) {
          return '[@' + item.original.key + '](@' + item.original.value + ')';
        },
      })
      tribute.attach(this);
    })

    $('.linkify').linkify();

    $('.comment-body').each(function() {
      $(this).html($(this).html().replace(/<a (.*)>(.*)<\/a>/, function(match, p1, p2) {
        parts = p2.split('/')
        if (p2.match(/^(http|https):\/\//) && p2.length > 50 && parts.length > 3) {
          t = parts[0] + '//' + parts[2] + '/...'
        } else {
          t = p2
        }
        return '<a ' + p1 + '>' + t + '</a>'
      }))
    })

    $('.nl2br').each(function() {
      $(this).html(nl2br($(this).html()))
    })

    $('.tagify').each(function() {
      $(this).html($(this).html().replace(/\[@([\w\s'-\.]+)\]\(@(\w+)\)/g, '<a href="/u/$2">$1</a>'));
    })
  }

  $(document).ajaxComplete(function() {
    ajaxCompleted()
  });
  ajaxCompleted()

  $('input[type=hidden].lookup').each(function() {
    $(this).lookup({
      lookup_url: $(this).attr('data-lookup-url'),
      placeholder: $(this).attr('placeholder'),
      id_param: 'id'
    });
  });

  $('form').submit(function() {
    $('button[type=submit]', this).attr('disabled', 'disabled').html('Submitting...');
  });

  $('[data-upload-url]').click(function() {
    var form = $('<form action="' + $(this).attr('data-upload-url') + '" method="post" enctype="multipart/form-data"><input style="display: none" type="file" name="upload"></form>')
    form.insertAfter(this)
    form.find('input').click().change(function() {
      this.form.submit()
    })
  })

  $('input[type=text].slug').each(function() {
    var slug = $(this);
    var start_length = slug.val().length;
    var pos = $.inArray(this, $('input', this.form)) - 1;
    var title = $($('input', this.form).get(pos));
    slug.focus(function() {
      slug.data('focus', true);
    });
    title.keyup(function() {
      if (start_length == 0 && slug.data('focus') != true)
        slug.val(title.val().toLowerCase().replace(/ /g, '-').replace(/[^a-z0-9\-]/g, ''));
    });
  });

  $(document).on('click', 'a.popup', function(e) {
    window.open(this.href, null, 'scrollbars=yes,width=600,height=600,left=150,top=150').focus();
    return false;
  });
  
  if (window.location.hash.startsWith('#photo-'))
    $("[data-target='"+window.location.hash+"']").click()

  $('textarea.wysiwyg').each(function() {
    var textarea = this
    var editor = textboxio.replace(textarea, {
      css: {
        stylesheets: ['/stylesheets/app.css']
      },
      paste: {
        style: 'plain'
      },
      images: {
        allowLocal: false
      }
    });
    if (textarea.form)
      $(textarea.form).submit(function() {
        if ($(editor.content.get()).text().trim() == '') {
          editor.content.set(' ')
          $(textarea).val(' ')
        }
      })
  });

});
