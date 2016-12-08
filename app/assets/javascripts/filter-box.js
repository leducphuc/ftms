var open_select_event_target;

$(document).on("turbolinks:load", function () {
  restore_filter_session();
  filter_date();
  validateFilterRank();
  intSearcher();
  resetOrder();
  show_blank_option();

  $('div.dropdown').on('hide.bs.dropdown', function() {
    $(':checkbox').each(function(i,item){
      this.checked = item.defaultChecked;
    });
  });

  $('#filter_form').submit(function(e) {
    if ($('#month-from').length == 0 && $('#month-to').length == 0) {
      var filter_date = sessionStorage.getItem('filter_date');
      if (filter_date) {
        filter_date = filter_date.split("-");
        var locations = [];
        var stages = [];

        $('input:checkbox:not(:checked)', '#locations-checkbox').each(function() {
          locations.push($(this).val());
        });
        $('input:checkbox:not(:checked)', '#stages-checkbox').each(function() {
          stages.push($(this).val());
        });

        $('<input>').attr({
          type: 'hidden',
          id: 'filter_start_date',
          name: 'start_date',
          value: filter_date[0]
        }).appendTo('form#filter_form');

        $('<input>').attr({
          type: 'hidden',
          id: 'filter_end_date',
          name: 'end_date',
          value: filter_date[1]
        }).appendTo('form#filter_form');

        store_session(locations, stages, filter_date[0], filter_date[1]);
      }
    } else {
      set_filter_date_value();
    }
    return true;
  })
});

$(window).on("resize", function(){
  updateFilterPosition();
});

$(document).on("click", ".filters .filter_actions a", function () {
  var val = $(this).hasClass("filter_select");
  var filtersWrapper = $(this).parents(".filters");
  filtersWrapper.find("input[type=checkbox]:visible").each(function () {
    if(!$(this).is(":disabled")){
      this.checked = val;
    }
  });

  filtersWrapper.find("input[type=number]").each(function () {
    this.value = "";
  });

  filtersWrapper.find("input[type=text]:not(.search_filter)").each(function () {
    this.value = "";
    intSearcher();
  });

  filtersWrapper.find(".datepicker").each(function () {
    this.value = "";
  });

  show_blank_option();
});

$(document).on('click', '.open-select', function (event) {
  event.preventDefault();
  open_select_event_target = event.target;
  toggleFilterMenu($(this), false);
});

function validateFilterRank() {
  $(".rank_filter_field").change(function() {
    var max = $(this).attr("max");
    var min = $(this).attr("min");
    var current_value = parseFloat($(this).val());
    if(current_value > max)
      current_value = max;
    if(current_value < min)
      current_value = min;
    $(this).val(current_value);
  });
}

function quick_search_manager(inputElement, search_path, loading_path, selector) {
  selector = selector || "label";
  inputElement.quicksearch(search_path, {
    "delay": 100,
    "selector": selector,
    "bind": "keyup",
    "loader": loading_path,
    prepareQuery: function (val) {
      val = val.replace(',', '');
      return val.toLowerCase().split(' ');
    },
    testQuery: function (query, txt, _row) {
      for (var i = 0; i < query.length; i += 1) {
        txt = txt.replace(',', '');
        if (txt.indexOf(query[i]) === -1) {
          return false;
        }
      }
      return true;
    }
  });
}

function toggleFilterMenu(element, resize) {
  var filterName = element.data("name");
  var $filterDom = $("." + filterName);

  if ($filterDom.length == 0) return;

  var _left, _top;
  var windowWidth = $(window).width();
  var filterDomWidth = $filterDom.outerWidth();

  var filterClass = "filters";
  var rightArowClass = "filter-right-arow";

  $("." + filterClass).not($filterDom).hide();

  var fa = element.find(".fa");
  if (fa.offset().left + filterDomWidth > windowWidth) {
    $filterDom.addClass(rightArowClass);
    _left = fa.offset().left - filterDomWidth + 24;
  } else if (fa.hasClass('controller_name')) {
    _left = 470;
  } else {
    $filterDom.removeClass(rightArowClass);
    _left = fa.offset().left - 12;
  }

  _top = fa.offset().top + fa.outerHeight();
  if (document.getElementById('universities-statistic') != null) {
    _top -= $($('.box-title')[1]).offset().top;
  }

  if (fa.hasClass('controller_name')) {
    _top = $(".panel").offset().top - 44;
  }

  $filterDom.css({"top": _top, "left": _left});

  if (!resize) {
    $filterDom.toggle();
    loadDataFilter(open_select_event_target);
  }

  if ($("div.filters").is(":visible")) {
    $("input#manager-search").focus();
    $("input.date_input:visible").focus();
    $("input.rank_filter_field:visible").focus();
    $("input.search_filter:visible").focus();
  }
}

function updateFilterPosition() {
  var $filterVisible = $(".filters:visible");
  if ($filterVisible.length > 0) {
    toggleFilterMenu($('.open-select[data-name="f-' + $filterVisible.data("parent") + '"]'), true);
  }
}

function intSearcher(){
  $("div.filters").each(function(){
    var parent_name = $(this).data("parent");
    var month = $(this).data("month") || "";
    if (month != "") {
      parent_name += "_" + month;
    }
    var $inputElement = $("input#manager-search-" + parent_name);
    var search_path = ".f-" + parent_name + " .options .option";
    quick_search_manager($inputElement, search_path, "label.quick-searching");
  });
}

function loadDataFilter(target) {
  var filter_data = $("#filter").attr("data-filter-data");
  var list_select;
  var list_range;
  var list_date;

  data_name = $(target).parent().data('name');
  data_parent = $('.' + data_name).data('column');
  checkbox_type = '.filter :input[type="checkbox"]';

  try {
    if (filter_data != '') {
      data = JSON.parse(filter_data);
    }

    if (data.list_filter_select != undefined) {
      list_select = data.list_filter_select[data_parent];
    }

    if (data.list_filter_range != undefined) {
      list_range = data.list_filter_range[data_parent];
    }

    if (data.list_filter_date != undefined) {
      list_date = data.list_filter_date[data_parent];
    }
  } catch (e) {
    console.log('Parse ------->' + e);
  }



  name_list_resourse = $.map($(checkbox_type), function(item){
    return $(item).val();
  });

  var rows_buffer = Array();
  var list_visible_row = Array();

  $('.filter_table_left_part .trow').each(function(index, element){
    rows_buffer.push({'left_part': $(element)});
  });
  $('.filter_table_right_part .trow').each(function(index, element){
    rows_buffer[index]['right_part'] = $(element);
  });

  rows_buffer.forEach(function(row) {
    var row_is_visible = false;
    var cell_element;
    var cell_value;
    for(var row_child in row){
      cell_element = row[row_child].children("." + data_parent);
      if (cell_element.length != 0){
        if (!row[row_child].hasClass('hide')) {
          cell_value = $.trim(cell_element.text().toLowerCase());
          if (data_name == "f-course_trainers") {
            cell_value = cell_value.split(', ');
          }
          row_is_visible = true;
        }
        break;
      }
    }

    if(row_is_visible) {
      if (data_name == "f-course_trainers") {
        list_visible_row = list_visible_row.concat(cell_value);
      } else {
        list_visible_row.push(cell_value);
      }
    }
  });

  if (list_visible_row != undefined) {
    $.each($(checkbox_type), function(index, item) {
      var value = $(item).val().toLowerCase();
      if ($.inArray(value, list_visible_row) != -1){
        $(item).prop('checked', true);
      } else {
        $(item).prop('checked', false);
      }
    });
  }

  if (list_range != undefined) {
    $(".filter #min_value").val(list_range[0]);
    $(".filter #max_value").val(list_range[1]);
  }

  if (list_date != undefined) {
    $(".filter .start_date").val(list_date[0]);
    $(".filter .end_date").val(list_date[1]);
  }
}
function filter_date() {
  $('#month-filter').click(function() {
    html = "<div class='filters f-filter-month'><div>"+I18n.t("buttons.from")+"<input type='text' name='month-from' id='month-from' class='date_input'></div><div class='margin-top-20'>"+I18n.t("buttons.to")+"<input type='text' name='month-to' id='month-to' class='date_input'></div><hr><a class='btn btn-primary btn-sm' href='javascript:void(0)' id='date_submit'>"+I18n.t("buttons.ok")+"</a><a href='javascript:void(0)' class='btn btn-sm btn-default button-cancel'>"+I18n.t("buttons.cancel")+"</a></div>";
    $('.filter-form').html(html);
    var filter_date = sessionStorage.getItem('filter_date');
    if (filter_date) {
      filter_date = filter_date.split("-");
      $('#month-from').val(filter_date[0]);
      $('#month-to').val(filter_date[1]);
    }

    $('.date_input').bind('focus', function() {
      $('.date_input').datepicker({
        format: I18n.t("datepicker.time.short"),
        viewMode: 'months',
        minViewMode: 'months',
        autoclose: true
      });
    });
  });
}

$(document).on('click', '#date_submit', function() {
  var locations = [];
  var stages = [];
  var start_date = $('#month-from').val();
  var end_date = $('#month-to').val();

  set_filter_date_value();
  $('input:checkbox:not(:checked)', '#locations-checkbox').each(function() {
    locations.push($(this).val());
  });
  $('input:checkbox:not(:checked)', '#stages-checkbox').each(function() {
    stages.push($(this).val());
  });
  if (Date.parse(start_date) && Date.parse(end_date)) {
    var href_locations = "";
    var href_stages = "";
    if (locations.length > 0) {
      href_locations = "&location_ids=" + locations;
    }
    if (stages.length > 0) {
      href_stages = "&stage_ids=" + stages;
    }
    store_session(locations, stages, start_date, end_date);

    var filter_type = "?type=total_trainees";
    href = location.protocol + '//' + location.host + location.pathname
      + filter_type + "&start_date=" + start_date + "&end_date=" + end_date + href_locations + href_stages;
    $(this).attr('href', href);
  }
});

function restore_filter_session() {
  var not_checked_locations = sessionStorage.getItem('not_checked_locations');
  var not_checked_stages = sessionStorage.getItem('not_checked_stages');
  if (not_checked_locations) {
    not_checked_locations = not_checked_locations.split(',');
    $(':checkbox', '#locations-checkbox').each(function(index, value) {
      if ($.inArray($(value).val(), not_checked_locations) == -1) {
        $(value).prop('checked', true);
      } else {
        $(value).prop('checked', false);
      }
    });
  }

  if (not_checked_stages) {
    not_checked_stages = not_checked_stages.split(',');
    $(':checkbox', '#stages-checkbox').each(function(index, value) {
      if ($.inArray($(value).val(), not_checked_stages) == -1) {
        $(value).prop('checked', true);
      } else {
        $(value).prop('checked', false);
      }
    });
  }
}

function store_session(locations, stages, start_date, end_date) {
  sessionStorage.setItem('not_checked_locations', locations);
  sessionStorage.setItem('not_checked_stages', stages);
  sessionStorage.setItem('filter_date', start_date + "-" + end_date);
}

function set_filter_date_value() {
  var from = $('#month-from').val();
  var to = $('#month-to').val();
  var filter_start_date = $('#filter_start_date');
  var filter_end_date = $('#filter_end_date');
  var locations = [];
  var stages = [];

  $('input:checkbox:not(:checked)', '#locations-checkbox').each(function() {
    locations.push($(this).val());
  });
  $('input:checkbox:not(:checked)', '#stages-checkbox').each(function() {
    stages.push($(this).val());
  });

  if (Date.parse(from) && Date.parse(to)) {
    if (filter_start_date > 0 && filter_end_date > 0) {
      filter_start_date.val(from);
      filter_end_date.val(to);
    } else {
      $('<input>').attr({
        type: 'hidden',
        id: 'filter_start_date',
        name: 'start_date',
        value: from
      }).appendTo('form#filter_form');

      $('<input>').attr({
        type: 'hidden',
        id: 'filter_end_date',
        name: 'end_date',
        value: to
      }).appendTo('form#filter_form');
    }
    store_session(locations, stages, from, to);
  }
}
