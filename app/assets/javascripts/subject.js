function load_chart() {
  $('#user-subjects-charts').highcharts({
    chart: {
      type: 'column'
    },
    title: {
      text: I18n.t('user_subjects.chart.title')
    },
    xAxis: {
      categories: $('#user-subjects-charts').data('user-name'),
      crosshair: true
    },
    yAxis: {
      min: 0,
      title: {
        text: I18n.t('user_subjects.chart.y_axis')
      }
    },
    tooltip: {
      headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
      pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
      '<td style="padding:0"><b>{point.y}</b></td></tr>',
      footerFormat: '</table>',
      shared: true,
      useHTML: true
    },
    plotOptions: {
      column: {
        pointPadding: 0.2,
        borderWidth: 0
      }
    },
    series: [{
      name: I18n.t('user_subjects.chart.task_total'),
      data: $('#user-subjects-charts').data('total-number-tasks')
    }]
  });
}

function setbutton() {
  $('.btn-reject').click(function () {
    this.href = this.href + '?status=reject';
  });

  $('.btn-finish').click(function () {
    this.href = this.href + '?status=finish';
  });

  $('.btn-reopen').click(function () {
    this.href = this.href + '?status=reopen';
  });

  $('.finish-subject').click(function(e) {
    e.preventDefault();
    var exec_finish = document.getElementById('finish-subject-exam');
    if (exec_finish) {
      $("#dialog-finish").dialog({
        modal: true,
        width: 550,
        buttons: [
          {
            text: I18n.t("user_subjects.finish.with_exam"),
            click: function() {
              exec_finish.href = exec_finish.href + '?exam=now';
              $(exec_finish).trigger('click');
            }
          },
          {
            text: I18n.t("user_subjects.finish.without_exam"),
            click: function() {
              $(exec_finish).trigger('click');
            }
          },
          {
            text: I18n.t("buttons.cancel"),
            click: function() {$(this).dialog('close');}
          }
        ]
      });
    } else {
      exec_finish = document.getElementById('finish-subject-project');
      $("#dialog-finish").dialog({
        modal: true,
        width: 300,
        buttons: [
          {
            text: I18n.t("user_subjects.finish.with_present"),
            click: function() {
              $(exec_finish).trigger('click');
            }
          },
          {
            text: I18n.t("buttons.cancel"),
            click: function() {$(this).dialog('close');}
          }
        ]
      });
    }
  });
}

$(document).on('turbolinks:load', function() {
  var tbl_subject = $('#subjects');
  if (tbl_subject.length > 0) {
    set_datatable(tbl_subject, [0, 2]);
  }
  load_chart();
  setbutton();
});

$(document).on('ajaxComplete', function(){
  if ($('.user-lists').length) {
    setbutton();
  } else {
    load_chart();
  }
});

