// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.addEventListener('load', async () => {
  /**
   * Inject hyperlinks, into the column headers of sortable tables, which sort
   * the corresponding column when clicked.
   */
  var tables = document.querySelectorAll("table.sortable"),
    table,
    thead,
    headers,
    i,
    j;

  for (i = 0; i < tables.length; i++) {
    table = tables[i];

    if (thead = table.querySelector("thead")) {
      headers = thead.querySelectorAll("th");

      for (j = 0; j < headers.length; j++) {
        headers[j].innerHTML = "<a href='#'>" + headers[j].innerText + "</a>";
      }

      thead.addEventListener("click", sortTableFunction(table));
    }
  }

  /**
   * Create a function to sort the given table.
   */
  function sortTableFunction(table) {
    return function (ev) {
      if (ev.target.tagName.toLowerCase() == 'a') {
        sortRows(table, siblingIndex(ev.target.parentNode));
        ev.preventDefault();
      }
    };
  }

  /**
   * Get the index of a node relative to its siblings — the first (eldest) sibling
   * has index 0, the next index 1, etc.
   */
  function siblingIndex(node) {
    var count = 0;

    while (node = node.previousElementSibling) {
      count++;
    }

    return count;
  }

  /**
   * Sort the given table by the numbered column (0 is the first column, etc.)
   */
  function sortRows(table, columnIndex) {
    var rows = table.querySelectorAll("tbody tr"),
      sel = "thead th:nth-child(" + (columnIndex + 1) + ")",
      sel2 = "td:nth-child(" + (columnIndex + 1) + ")",
      classList = table.querySelector(sel).classList,
      values = [],
      cls = "",
      allNum = true,
      val,
      index,
      node;

    if (classList) {
      if (classList.contains("date")) {
        cls = "date";
      } else if (classList.contains("number")) {
        cls = "number";
      }
    }

    for (index = 0; index < rows.length; index++) {
      node = rows[index].querySelector(sel2);
      val = node.innerText;

      if (isNaN(val)) {
        allNum = false;
      } else {
        val = parseFloat(val);
      }

      values.push({ value: val, row: rows[index] });
    }

    if (cls == "" && allNum) {
      cls = "number";
    }

    if (cls == "number") {
      console.log(values)
      values.sort(sortNumberVal);
      console.log(values)
      values = values.reverse();
    } else if (cls == "date") {
      values.sort(sortDateVal);
    } else {
      values.sort(sortTextVal);
    }

    for (var idx = 0; idx < values.length; idx++) {
      table.querySelector("tbody").appendChild(values[idx].row);
    }
  }

  /**
   * Compare two 'value objects' numerically
   */
  function sortNumberVal(a, b) {
    var a_value = String(a.value).replace(/[^0-9\.]+/g, "");
    var b_value = String(b.value).replace(/[^0-9\.]+/g, "");
    return sortNumber(a_value, b_value);
  }

  /**
   * Numeric sort comparison
   */
  function sortNumber(a, b) {
    return a - b;
  }

  /**
   * Compare two 'value objects' as dates
   */
  function sortDateVal(a, b) {
    var dateA = Date.parse(a.value),
      dateB = Date.parse(b.value);

    return sortNumber(dateA, dateB);
  }

  /**
   * Compare two 'value objects' as simple text; case-insensitive
   */
  function sortTextVal(a, b) {
    var textA = (a.value + "").toUpperCase();
    var textB = (b.value + "").toUpperCase();

    if (textA < textB) {
      return -1;
    }

    if (textA > textB) {
      return 1;
    }

    return 0;
  }

});