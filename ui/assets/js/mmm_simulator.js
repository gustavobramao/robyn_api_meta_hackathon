$(document).ready(function () {
    Highcharts.theme = {
        colors: ['#9367B4', '#17C2D7', '#003f5c', '#58508d', '#a0e8c0', '#ff6361', '#3B4A8C', '#FFF263', '#6AF9C4'],
        title: {
            style: {
                color: '#000',
                font: 'bold 14px "Source Sans Pro", Verdana, sans-serif'
            }
        },
        subtitle: {
            style: {
                color: '#666666',
                font: 'bold 12px "Source Sans Pro", Verdana, sans-serif'
            }
        },
        legend: {
            itemStyle: {
                font: '9pt "Source Sans Pro", Verdana, sans-serif',
                color: 'black'
            },
            itemHoverStyle: {
                color: 'gray'
            }
        },
        global: {
            useUTC: false,
        },
        lang: {
            decimalPoint: '.',
            thousandsSep: ','
        }
    };

    Highcharts.setOptions(Highcharts.theme);

    function bootstrapAjax(xhr, settings) {
        showBlock("loader");
    }

    function renderDataTable(data) {
        $('#simulator-table').DataTable().destroy();
        $('#simulator-table').dataTable({
            initComplete: function () {
                showBlock('table');
            },
            "rowCallback": function (row, data, index) {
                $(row).find('td:eq(2)').css('background-color', 'rgba(10,121,255,' + data.initROAS + ')');
                if (data.initROAS > 0.6) {
                    $(row).find('td:eq(2)').addClass('text-light')
                }

                $(row).find('td:eq(6)').css('background-color', 'rgba(10,121,255,' + data.optmROAS + ')');
                if (data.optmROAS > 0.6) {
                    $(row).find('td:eq(6)').addClass('text-light')
                }
            },
            colReorder: {
                order: [11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            },
            "columnDefs": [
                {
                    targets: [2, 3, 7, 8],
                    render: $.fn.dataTable.render.number(',', '.', 1, '')
                },
                {
                    targets: [1, 4, 6, 9],
                    render: $.fn.dataTable.render.number(',', '.', 0, '')
                },
                {
                    targets: [2, 7],
                    visible: false
                },
                {
                    targets: [0, 5],
                    render: $.fn.dataTable.render.number(',', '.', 0, '', '%')
                }
            ],
            "aaData": data,
            "columns": [
                { "data": "initCiR" },
                { "data": "initNmV" },
                { "data": "initROAS" },
                { "data": "initRoiUnit" },
                { "data": "initSpendUnit" },
                { "data": "optmCiR" },
                { "data": "optmNmV" },
                { "data": "optmROAS" },
                { "data": "optmRoiUnit" },
                { "data": "optmSpendUnit" },
                { "data": "_row" },
            ]
        });
    }

    $.ajaxSetup({
        crossDomain: true,
        beforeSend: bootstrapAjax
    });

    $.validator.setDefaults({
        submitHandler: function () {
            $.get("http://127.0.0.1:3000/robyn_scenarios_endpoint", convertFormToJSON($('#simulator-form')))
                .done(function (data) {
                    renderDataTable(data[0])
                    renderPlots(data)
                }).fail(function (data) {
                    showBlock("error");
                });
        }
    });

    $("#simulator-form").validate(
        {
            errorElement: 'span',
            errorPlacement: function (error, element) {
                error.addClass('invalid-feedback');
                element.closest('.form-group').append(error);
            },
            highlight: function (element, errorClass, validClass) {
                $(element).addClass('is-invalid');
            },
            unhighlight: function (element, errorClass, validClass) {
                $(element).removeClass('is-invalid');
            }
        }
    );

});

function renderPlots(data) {
    renderSpendSharePlot(data[2])
    renderMeanResponsePlot(data[3])
    renderResponseCurvePLot(data[1], data[4])
}

function renderSpendSharePlot(data) {
    let mapped = [], categories = [], series_data_map = [], series_data = [];
    let s = data.map(function (row) {
        if (!mapped[row.channel]) {
            mapped[row.channel] = []
        }
        mapped[row.channel][row.variable] = row.spend_share;
    });

    Object.keys(mapped).forEach(function (key) {
        categories.push(key)
        Object.keys(mapped[key]).forEach(function (k) {
            if (!series_data_map[k]) {
                series_data_map[k] = []
            }
            series_data_map[k].push(mapped[key][k])
        });
    });

    for (const series in series_data_map) {
        series_data.push({
            'name': series,
            'data': series_data_map[series],
            type: 'column',
            yAxis: 0,
            tooltip: {
                valueSuffix: '%'
            }
        })
    }

    $('#spend-share').highcharts({
        chart: {
            type: 'column',
            inverted: true
        },
        title: {
            text: '',
            align: 'center'
        },
        xAxis: {
            categories: categories,
            crosshair: true
        },
        credits: {
            enabled: false
        },
        series: series_data,
        yAxis: {
            min: 0,
            tickInterval: 0.1,
            labels: {
                formatter: function () {
                    return this.value * 100 + '%'
                },
                style: {
                    color: Highcharts.getOptions().colors[1]
                }
            },
            title: {
                text: ' ',
                style: {
                    color: Highcharts.getOptions().colors[1]
                }
            }
        },
        tooltip: {
            formatter: function () {
                return '<b>' + this.series.name + '</b>: ' + Highcharts.numberFormat(this.y * 100, 1) + ' %';
            }
        },
    });
}

function renderResponseCurvePLot(scurve_data, initOptimalData) {
    var series = [], series_data = [], initial_series = [], optimal_series = [], all_series = [];
    for (let idx in initOptimalData) {
        row = initOptimalData[idx]
        initial_series.push({ x: row.initSpendUnit, y: row.initResponseUnit })
        optimal_series.push({ x: row.optmSpendUnit, y: row.optmResponseUnit })
        all_series.push({ x: row.initSpendUnit, y: row.initResponseUnit })
        all_series.push({ x: row.optmSpendUnit, y: row.optmResponseUnit })
    }

    const max_mean_spend = all_series.reduce((a, b) => a.x > b.x ? a : b).x;
    const max_mean_response = all_series.reduce((a, b) => a.y > b.y ? a : b).y;
    const trim_rate = 1.3;

    $.each(scurve_data, function (iidx, row) {
        if (!series[row.channel]) {
            series[row.channel] = []
        }
        if (row.spend < max_mean_spend * trim_rate & row.response < max_mean_response * trim_rate) {
            series[row.channel].push({ x: row.spend, y: row.response });
        }
    });
    let i = 0;
    Object.keys(series).forEach(function (key) {
        if (series[key]) {
            series_data.push({
                "name": key,
                "data": series[key],
                "regression": true,
                "regressionSettings": {
                    "type": 'polynomial',
                    "color": Highcharts.getOptions().colors[i],
                    "order": 5,
                    "hideInLegend": true,
                    "visible": false
                }
            });
        }
        i++;
    });


    series_data.push({
        "name": 'Optimal',
        type: 'scatter',
        "data": optimal_series,
        dataLabels: {
            enabled: true,
            color: '#FFFFFF',
            formatter: function () {
                return Highcharts.numberFormat(this.x / 1000, 1) + 'K';
            }
        }
    });

    series_data.push({
        "name": 'Initial',
        type: 'scatter',
        "data": initial_series,
        dataLabels: {
            enabled: true,
            color: '#FFFFFF',
            formatter: function () {
                return Highcharts.numberFormat(this.x / 1000, 1) + 'K';
            }
        }
    });

    $('#response-curves').highcharts({
        chart: {
            type: 'line'
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            itemMarginTop: 10,
            itemMarginBottom: 10
        },
        title: {
            text: '',
            align: 'center'
        },
        plotOptions: {
            series: {
                stacking: 'normal'
            },
        },
        credits: {
            enabled: false
        },
        series: series_data,
        yAxis: [{
            gridLineWidth: 1,
            labels: {
                format: '{value}',
                style: {
                    color: Highcharts.getOptions().colors[1]
                }
            },
            title: {
                text: 'Response',
                style: {
                    color: Highcharts.getOptions().colors[1]
                }
            },
        }]
    });

}

function renderMeanResponsePlot(data) {
    let mapped = [], categories = [], series_data_map = [], series_data = [];
    let s = data.map(function (row) {
        if (!mapped[row.channel]) {
            mapped[row.channel] = []
        }
        mapped[row.channel][row.variable] = row.response;
    });

    Object.keys(mapped).forEach(function (key) {
        categories.push(key)
        Object.keys(mapped[key]).forEach(function (k) {
            if (!series_data_map[k]) {
                series_data_map[k] = []
            }
            series_data_map[k].push(mapped[key][k])
        });
    });

    for (const series in series_data_map) {
        series_data.push({
            'name': series,
            'data': series_data_map[series],
            type: 'column',
            yAxis: 0
        })
    }

    $('#mean-response-share').highcharts({
        chart: {
            type: 'column',
            inverted: true
        },
        title: {
            text: '',
            align: 'center'
        },
        xAxis: {
            categories: categories,
            crosshair: true
        },
        credits: {
            enabled: false
        },
        series: series_data,
        yAxis: [{ // Primary yAxis
            labels: {
                format: '{value}',
                style: {
                    color: Highcharts.getOptions().colors[1]
                }
            },
            title: {
                text: ' ',
                style: {
                    color: Highcharts.getOptions().colors[1]
                }
            }
        }],
    });
}

function showBlock(blockName) {
    $('#sim-empty,#sim-loader,#sim-table,#sim-error').addClass("d-none")
    $('#sim-' + blockName).removeClass("d-none")
}

function convertFormToJSON(form) {
    return $(form)
        .serializeArray()
        .reduce(function (json, { name, value }) {
            json[name] = value;
            return json;
        }, {});
}