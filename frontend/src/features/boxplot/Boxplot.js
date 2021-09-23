import { useState } from "react";
import Chart from "react-apexcharts";
import SensorToggleButton from "./ToggleButton";

export const Boxplot = () => {
  const [series,] = useState([
    {
      name: "pH Value",
      type: "boxPlot",
      data: [
        {
          x: 'Bouy 1',
          y: [54, 66, 69, 75, 88],
        },
        {
          x: 'Bouy 2',
          y: [43, 65, 69, 76, 81],
        },
        {
          x: 'Bouy 3',
          y: [31, 39, 45, 51, 59],
        },
      ],
    },
    {
      name: "Dissolved Solids",
      type: "scatter",
      data: [
        {
          x: 'Bouy 1',
          y: 32,
        },
        {
          x: 'Bouy 2',
          y: 25,
        },
        {
          x: 'Bouy 3',
          y: 64,
        },
      ],
    },
  ]);

  const [options,] = useState({
    chart: {
      type: "boxPlot",
      width: '400',
      toolbar: {
        tools: {
          download: true,
          zoom: false,
          zoomin: false,
          zoomout: false,
          pan: false,
          reset: false
        },
      },
    },
    colors: ["#008FFB", "#FEB019"],
    title: {
      text: "BoxPlot - Last 24 h",
      align: "left",
    },
    xaxis: {
      type: "categories",
      tooltip: {
        enabled: false,
      },
    },
    yaxis: {
      title: {
          text: 'pH Value [-]'
      }
  },
    

    tooltip: {
      shared: false,
      intersect: true,
    },
  });

  return (
    <div>
    <div id="chart">
      <Chart
        options={options}
        series={series}
        type="boxPlot"
        height={'350'}
      />
    </div>
    <div> <SensorToggleButton size="large"/> </div>
    </div>
  );
};
