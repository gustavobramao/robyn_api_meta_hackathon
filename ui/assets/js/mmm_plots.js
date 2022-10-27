$(document).ready(function () {
    function plot_share_chart() {
        $.get('/data/df1.csv', function (csv) {
            let lines = csv.split('\n'), categories = [], series = {
                'roi': [],
                'effect_share': [],
                'spend_share': []
            };
            for (var i = 0; i < lines.length; i++) {
                if (i != 0 && lines[i] != '') {
                    let cols = lines[i].split(',');
                    let channel = cols[0];
                    let plot_variable = cols[4];
                    let plot_value = cols[5];
                    let roi_value = cols[11];
                    if (!categories.includes(channel)) {
                        categories.push(channel)
                    }
                    series[plot_variable].push(parseFloat(plot_value) * 100)
                    if (plot_variable == 'effect_share') {
                        series['roi'].push(parseFloat(roi_value))
                    }
                }
            }

            $('#share-roi').highcharts({
                chart: {
                    type: 'column',
                    inverted: true
                },
                title: {
                    text: '',
                    align: 'center'
                },
                credits: {
                    enabled: false
                },
                xAxis: {
                    categories: categories
                },
                series: [{
                    name: 'Spend Share',
                    type: 'column',
                    yAxis: 0,
                    tooltip: {
                        pointFormatter: function () {
                            return Highcharts.numberFormat(this.y, 1) + ' %';
                        }
                    },
                    data: series['spend_share']
                },
                {
                    name: 'Effect Share',
                    type: 'column',
                    yAxis: 0,
                    tooltip: {
                        pointFormatter: function () {
                            return Highcharts.numberFormat(this.y, 1) + ' %';
                        }
                    },
                    data: series['effect_share']
                },
                {
                    name: 'ROI',
                    type: 'line',
                    yAxis: 1,
                    data: series['roi'],
                    tooltip: {
                        pointFormatter: function () {
                            return Highcharts.numberFormat(this.y, 1);
                        }
                    },
                }],
                yAxis: [{
                    labels: {
                        format: '{value}',
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    },
                    title: {
                        text: 'Spend share | Efffect share',
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    }
                }, {
                    title: {
                        text: 'roi',
                        style: {
                            color: Highcharts.getOptions().colors[0]
                        }
                    },
                    labels: {
                        format: '{value}',
                        style: {
                            color: Highcharts.getOptions().colors[0]
                        }
                    },
                    opposite: true
                }],
            });
        });
    }
    function plot_adstock_chart() {
        $.get('/data/df3.csv', function (csv) {
            $('#geometric-adstock').highcharts({
                chart: {
                    type: 'column',
                    inverted: true
                },
                data: {
                    csv: csv
                },
                title: {
                    text: '',
                    align: 'center'
                },
                legend: {
                    enabled: false
                },
                credits: {
                    enabled: false
                },
                series: [{
                    type: 'column',
                }],
                yAxis: {
                    labels: {
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        },
                        formatter: function () {
                            return this.value * 100 + '%'
                        }
                    },
                    title: {
                        text: 'Decay Rate (%)',
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    },
                    min: 0,
                    max: 1,
                    tickInterval: 0.2
                },
                tooltip: {
                    formatter: function () {
                        return Highcharts.numberFormat(this.y * 100, 1) + ' %';
                    }
                },
            });
        });
    }
    function plot_prediction_chart() {
        $.get('/data/df5.csv', function (csv) {
            let lines = csv.split('\n');
            let series = {
                'actual': [],
                'predicted': []
            };
            for (var i = 0; i < lines.length; i++) {
                if (i != 0 && lines[i] != '') {
                    let cols = lines[i].split(',');
                    let date = cols[0];
                    let plot_variable = cols[1];
                    let plot_value = cols[2];
                    series[plot_variable].push({ x: new Date(date), y: parseFloat(plot_value) })
                }
            }
            $('#actual-predicted').highcharts({
                chart: {
                    type: 'line'
                },
                title: {
                    text: '',
                    align: 'center'
                },
                xAxis: {
                    type: 'datetime'
                },
                credits: {
                    enabled: false
                },
                series: [{
                    name: 'Actual',
                    type: 'line',
                    yAxis: 0,
                    data: series['actual']
                },
                {
                    name: 'Predicted',
                    type: 'line',
                    data: series['predicted'],
                    dashStyle : 'ShortDash'
                }],
                yAxis: [{
                    labels: {
                        formatter: function () {
                            return Highcharts.numberFormat(this.value / 1000, 0) + 'K';
                        },
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    },
                    title: {
                        text: 'Response',
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    }
                }, {
                    title: {
                        text: '',
                        style: {
                            color: Highcharts.getOptions().colors[0]
                        }
                    },
                    labels: {
                        format: '{value}',
                        style: {
                            color: Highcharts.getOptions().colors[0]
                        }
                    },
                    opposite: true
                }],
                tooltip: {
                    pointFormatter: function () {
                        return Highcharts.numberFormat(this.y, 0);
                    }
                },

            });
        });
    }
    function plot_decomposition_chart() {
        $.get('/data/df2.csv', function (csv) {
            let lines = csv.split('\n');
            let series = [];
            for (var i = 0; i < lines.length; i++) {
                if (i != 0 && lines[i] != '') {
                    let cols = lines[i].split(',');
                    let channel = cols[1];
                    let plot_value = cols[3];
                    series.push({
                        name: channel,
                        y: parseFloat(plot_value),
                    })
                }
            }
            series.sort((a, b) => b.y - a.y)
            $('#decomposition').highcharts({
                chart: {
                    type: 'waterfall',
                    inverted: true
                },
                title: {
                    text: ''
                },
                xAxis: {
                    type: 'category'
                },
                negativeColor: '#dc3545',
                yAxis: {
                    title: {
                        text: 'USD'
                    }
                },
                legend: {
                    enabled: false
                },
                tooltip: {

                    formatter: function () {
                        var dataSum = 0,
                            pcnt;

                        this.series.points.forEach(function (point) {
                            dataSum += point.y;
                        });

                        pcnt = (this.y / dataSum) * 100;

                        return Highcharts.numberFormat(pcnt) + '%';
                    },

                    pointFormat: '{y} % <br/> '
                },
                credits: {
                    enabled: false
                },
                series: [{
                    data: series,
                    dataLabels: {
                        enabled: true,
                        formatter: function () {
                            return Highcharts.numberFormat(this.y / 1000, 0) + 'k';
                        },
                        style: {
                            fontWeight: 'bold'
                        }
                    },
                    negativeColor: '#FF0000',
                    pointPadding: 0
                }]
            });
        });
    }
    function plot_mean_scurve_chart() {
        $.when($.get('/data/df4_s.csv'), $.ajax('/data/df4_e.csv')).done(function (scurve_data, mean_data) {
            scurve_data = scurve_data[0];
            mean_data = mean_data[0];

            let mean_series = [],
                mean_lines = mean_data.split('\n'),
                mean_channels = [],
                mean_spends = [];
            $.each(mean_lines, function (iidx, line) {
                mean_cols = line.split(',');
                if (iidx != 0 && mean_cols[1]) {
                    mean_channels.push(mean_cols[0])
                    mean_series.push({ x: Number(mean_cols[1]), y: Number(mean_cols[3]) })
                }
            });

            const max_mean_spend = mean_series.reduce((a, b) => a.x > b.x ? a : b).x;
            const max_mean_response = mean_series.reduce((a, b) => a.y > b.y ? a : b).y;
            const trim_rate = 1.3;

            let series = [],
                lines = scurve_data.split('\n'),
                cols;
            $.each(lines, function (iidx, line) {
                cols = line.split(',');
                if (iidx != 0 && cols[1]) {
                    if (!mean_channels.includes(cols[1])) {
                        return
                    }
                    if (!series[cols[1]]) {
                        series[cols[1]] = []
                    }
                    /* To be done in Backend or R */
                    if (Number(cols[3]) < max_mean_spend * trim_rate & Number(cols[2]) < max_mean_response * trim_rate) {
                        series[cols[1]].push({ x: Number(cols[3]), y: Number(cols[2]) });
                    }
                }
            });
            series_data = [];
            i = 0;
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
                "name": 'Mean Response',
                "type": 'scatter',
                "data": mean_series,
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
                    scatter: {
                        marker: {
                            radius: 3,
                            enabled: true,
                            states: {
                                hover: {
                                    enabled: true,
                                    lineColor: 'rgb(100,100,100)'
                                }
                            }
                        },
                        states: {
                            hover: {
                                marker: {
                                    enabled: false
                                }
                            }
                        },
                        tooltip: {
                            headerFormat: '<b>{series.name}</b><br>',
                            pointFormat: 'Spend : {point.x}, Response : {point.y}'
                        }
                    },
                },
                credits: {
                    enabled: false
                },
                series: series_data,
                xAxis: {
                    min: -10000,
                },
                yAxis: {
                    min: -10000,
                    startOnTick: false,
                    labels: {
                        formatter: function () {
                            return Highcharts.numberFormat(this.value / 1000, 0) + 'K';
                        },
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
                }
            });
        });
    }
    function plot_fitted_residual() {
        $.get('/data/df6_ci.csv', function (csv) {
            var series = [],
                lines = csv.split('\n'),
                cols;
            $.each(lines, function (iidx, line) {
                cols = line.split(',');
                if (iidx != 0 && cols[0]) {
                    let fit = cols[0]
                    let se = cols[1]
                    series.push({
                        'se' : Number(cols[1]),
                        'fit' : Number(cols[0]),
                        'actual' : Number(cols[2]),
                        'act_pred' : Number(cols[3]),
                        'predicted' : Number(cols[4]),
                    }) 
                }
            });
            let series_data_scatter = [];
            let series_data_range = [];
            let series_data_regression_line = [];
            series.forEach(function (row) {
                series_data_scatter.push({ x: row.predicted, y: row.act_pred });
                series_data_range.push({ x: row.predicted, low: row.fit-(2*row.se), high: row.fit+(2*row.se) })
                series_data_regression_line.push({ x: row.predicted, y: row.fit })
            });

            series_data_scatter.sort((a, b) => a.x - b.x)
            series_data_range.sort((a, b) => a.x - b.x)
            series_data_regression_line.sort((a, b) => a.x - b.x)

            $('#fitted-residual').highcharts({
                chart: {
                    type: 'scatter',
                },
                series: [
                    {
                        "name": "Fitted",
                        "data": series_data_scatter,
                        "color": Highcharts.getOptions().colors[1],
                        "marker" : {
                            "radius" : 2
                        }
                    },
                    {
                        type: 'line',
                        "name": "Fitted vs Residual",
                        "data": series_data_regression_line,
                        "color": Highcharts.getOptions().colors[2],
                        lineWidth: 1.5,
                    },
                    {
                        "name": "Fitted vs Residual",
                        "data": series_data_range,
                        type: 'arearange',
                        linkedTo: ':previous',
                        lineWidth: 0,
                        fillOpacity: 0.4,
                        "color": Highcharts.getOptions().colors[3]
                    },
                ],
                title: {
                    text: '',
                    align: 'center'
                },
                credits: {
                    enabled: false
                },
                yAxis: [{
                    labels: {
                        formatter: function () {
                            return Highcharts.numberFormat(this.value / 1000, 0) + 'K';
                        },
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    },
                    title: {
                        text: 'Residual',
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    },
                    plotLines: [{
                        value: 0,
                        color: 'black',
                        width: 1,
                        zIndex: 3
                   }],
                }],
                xAxis: {
                    labels: {
                        formatter: function () {

                            var axis = this.axis,
                                numericSymbols = this.chart.options.lang.numericSymbols,
                                i = numericSymbols && numericSymbols.length,
                                value = this.value,
                                ret;

                            if (this.value > 1000) {
                                while (i-- && ret === undefined) {

                                    multi = Math.pow(1000, i + 1);

                                    if (value * 10 % multi !== value * 10) {
                                        ret = Highcharts.numberFormat(value / multi, -1) + numericSymbols[i];
                                    }

                                }
                            }

                            return ret;
                        }
                    },
                    title: {
                        text: 'Fitted',
                        style: {
                            color: Highcharts.getOptions().colors[1]
                        }
                    },
                },
            });
        });
    }

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

    setTimeout(() => {
        plot_share_chart()
        plot_prediction_chart()
        plot_decomposition_chart()
        plot_adstock_chart()
        plot_mean_scurve_chart()
        plot_fitted_residual()
    }, 100);

});