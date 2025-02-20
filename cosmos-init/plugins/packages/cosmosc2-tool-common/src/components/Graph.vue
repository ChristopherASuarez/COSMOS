<!--
# Copyright 2021 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# This program may also be used under the terms of a commercial or
# enterprise edition license of COSMOS if purchased from the
# copyright holder
-->

<template>
  <div>
    <v-card @click.native="$emit('click')">
      <v-system-bar
        :class="selectedGraphId === id ? 'active' : 'inactive'"
        v-show="!hideSystemBar"
      >
        <div v-show="errors.length !== 0" class="mx-2">
          <v-tooltip top>
            <template v-slot:activator="{ on, attrs }">
              <div v-on="on" v-bind="attrs">
                <v-icon data-test="errorGraphIcon" @click="errorDialog = true">
                  mdi-alert
                </v-icon>
              </div>
            </template>
            <span> Errors </span>
          </v-tooltip>
        </div>

        <v-tooltip top>
          <template v-slot:activator="{ on, attrs }">
            <div v-on="on" v-bind="attrs">
              <v-icon data-test="editGraphIcon" @click="editGraph = true">
                mdi-pencil
              </v-icon>
            </div>
          </template>
          <span> Edit </span>
        </v-tooltip>

        <v-spacer />
        <span>{{ title }}</span>
        <v-spacer />

        <div v-show="expand">
          <v-tooltip top>
            <template v-slot:activator="{ on, attrs }">
              <div v-on="on" v-bind="attrs">
                <v-icon
                  data-test="collapseAll"
                  v-show="calcFullSize"
                  @click="collapseAll"
                >
                  mdi-arrow-collapse
                </v-icon>
                <v-icon
                  data-test="expandAll"
                  v-show="!calcFullSize"
                  @click="expandAll"
                >
                  mdi-arrow-expand
                </v-icon>
              </div>
            </template>
            <span v-show="calcFullSize"> Collapse </span>
            <span v-show="!calcFullSize"> Expand </span>
          </v-tooltip>
        </div>

        <div v-show="expand">
          <v-tooltip top>
            <template v-slot:activator="{ on, attrs }">
              <div v-on="on" v-bind="attrs">
                <v-icon
                  data-test="collapseWidth"
                  v-show="fullWidth"
                  @click="collapseWidth"
                >
                  mdi-arrow-collapse-horizontal
                </v-icon>
                <v-icon
                  data-test="expandWidth"
                  v-show="!fullWidth"
                  @click="expandWidth"
                >
                  mdi-arrow-expand-horizontal
                </v-icon>
              </div>
            </template>
            <span v-show="fullWidth"> Collapse Width </span>
            <span v-show="!fullWidth"> Expand Width </span>
          </v-tooltip>
        </div>

        <div v-show="expand">
          <v-tooltip top>
            <template v-slot:activator="{ on, attrs }">
              <div v-on="on" v-bind="attrs">
                <v-icon
                  data-test="collapseVertical"
                  v-show="fullHeight"
                  @click="collapseHeight"
                >
                  mdi-arrow-collapse-vertical
                </v-icon>
                <v-icon
                  data-test="expandVertical"
                  v-show="!fullHeight"
                  @click="expandHeight"
                >
                  mdi-arrow-expand-vertical
                </v-icon>
              </div>
            </template>
            <span v-show="fullHeight"> Collapse Height </span>
            <span v-show="!fullHeight"> Expand Height </span>
          </v-tooltip>
        </div>

        <v-tooltip top>
          <template v-slot:activator="{ on, attrs }">
            <div v-on="on" v-bind="attrs">
              <v-icon
                data-test="minimizeScreenIcon"
                @click="minMaxTransition"
                v-show="expand"
              >
                mdi-window-minimize
              </v-icon>
              <v-icon
                data-test="maximizeScreenIcon"
                @click="minMaxTransition"
                v-show="!expand"
              >
                mdi-window-maximize
              </v-icon>
            </div>
          </template>
          <span v-show="expand"> Minimize </span>
          <span v-show="!expand"> Maximize </span>
        </v-tooltip>

        <v-tooltip top>
          <template v-slot:activator="{ on, attrs }">
            <div v-on="on" v-bind="attrs">
              <v-icon
                data-test="closeGraphIcon"
                @click="$emit('close-graph')"
              >
                mdi-close-box
              </v-icon>
            </div>
          </template>
          <span> Close </span>
        </v-tooltip>
      </v-system-bar>

      <v-expand-transition>
        <div class="pa-1" id="chart" ref="chart" v-show="expand">
          <div :id="`chart${id}`"></div>
          <div :id="`overview${id}`" v-show="!hideOverview"></div>
        </div>
      </v-expand-transition>
    </v-card>

    <!-- Edit dialog -->
    <v-dialog
      v-model="editGraph"
      @keydown.esc="$emit('input')"
      @input="editGraphClose()"
      max-width="600"
    >
      <v-system-bar>
        <v-spacer />
        <span>Edit Graph</span>
        <v-spacer />
      </v-system-bar>
      <v-card class="pa-3">
        <v-row dense>
          <v-text-field
            class="pb-2"
            label="Title"
            v-model="title"
            hide-details
            data-test="editGraphTitle"
          />
        </v-row>
        <v-card-text class="pa-0">
          Select a start date/time for the graph. Leave blank for start now.
        </v-card-text>
        <date-time-chooser
          :required="false"
          dateLabel="Start Date"
          timeLabel="Start Time"
          @date-time="graphStartDateTime = $event"
        />
        <v-card-text class="pa-0">
          Select a end date/time for the graph. Leave blank for continuous
          real-time graphing.
        </v-card-text>
        <date-time-chooser
          dateLabel="End Date"
          timeLabel="End Time"
          @date-time="graphEndDateTime = $event"
        />
        <v-card-text class="pa-0">
          Optional Y axis settings.
        </v-card-text>
        <v-row dense>
          <v-col class="px-2">
            <v-text-field
              hide-details
              label="Min Y"
              v-model="graphMinY"
              type="number"
            />
          </v-col>
          <v-col class="px-2">
            <v-text-field
              hide-details
              label="Max Y"
              v-model="graphMaxY"
              type="number"
            />
          </v-col>
        </v-row>
          <v-data-table
            item-key="itemId"
            class="elevation-1 my-2"
            :headers="itemHeaders"
            :items="editItems"
            :items-per-page="5"
            :footer-props="{
              'items-per-page-options': [5],
            }"
          >
          <template v-slot:item.actions="{ item }">
            <v-tooltip top>
              <template v-slot:activator="{ on, attrs }">
                <div v-on="on" v-bind="attrs">
                  <v-btn
                    icon
                    :data-test="`deleteItemIcon${item.itemId}`"
                    @click="() => removeItems([item])"
                  >
                    <v-icon> mdi-delete </v-icon>
                  </v-btn>
                </div>
              </template>
              <span> Remove </span>
            </v-tooltip>
          </template>
          <template v-slot:no-data>
            <span>Currently no items on this graph</span>
          </template>
        </v-data-table>
        <v-card-actions>
          <v-btn color="primary" @click="editGraphClose()">
            Ok
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Error dialog -->
    <v-dialog v-model="errorDialog" max-width="600">
      <v-system-bar>
        <v-spacer />
        <span>Errors</span>
        <v-spacer />
      </v-system-bar>
      <v-card class="pa-3">
        <v-row dense>
          <v-text-field
            readonly
            hide-details
            v-model="title"
            class="pb-2"
            label="Graph Title"
          />
        </v-row>
        <v-row class="my-3">
          <v-textarea
            readonly
            rows="8"
            :value="error"
          />
        </v-row>
        <v-row>
          <v-btn block @click="clearErrors">
            Clear
          </v-btn>
        </v-row>
      </v-card>
    </v-dialog>

    <!-- Edit right click context menu -->
    <v-menu
      v-if="editGraphMenu"
      v-model="editGraphMenu"
      :position-x="editGraphMenuX"
      :position-y="editGraphMenuY"
      absolute
      offset-y
    >
      <v-list>
        <v-list-item @click="editGraph = true">
          <v-list-item-title style="cursor: pointer">
            Edit {{ title }}
          </v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>

    <!-- Edit Item dialog -->
    <v-dialog
      max-width="600"
      v-if="editItem"
      v-model="editItem"
      @keydown.esc="editItem = false"
    >
      <v-card class="pa-3">
        <v-card-title class="headline">Edit Item</v-card-title>
        <v-select
          outlined
          hide-details
          label="Value Type"
          :items="valueTypes"
          v-model="selectedItem.valueType"
          @change="changeType($event)"
        />
        <v-card-actions>
          <v-btn color="primary" @click="editItem = false">Ok</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Edit Item right click context menu -->
    <v-menu
      v-if="itemMenu"
      v-model="itemMenu"
      :position-x="itemMenuX"
      :position-y="itemMenuY"
      absolute
      offset-y
    >
      <v-list>
        <v-list-item @click="editItem = true">
          <v-list-item-title style="cursor: pointer">
            Edit {{ selectedItem.itemName }}
          </v-list-item-title>
        </v-list-item>
        <v-list-item @click="removeItems([selectedItem])">
          <v-list-item-title style="cursor: pointer">
            Delete {{ selectedItem.itemName }}
          </v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>
  </div>
</template>

<script>
import DateTimeChooser from './DateTimeChooser'
import uPlot from 'uplot'
import bs from 'binary-search'
import { toDate, format, getTime } from 'date-fns'
import Cable from '../services/cable.js'

require('uplot/dist/uPlot.min.css')

export default {
  components: {
    DateTimeChooser,
  },
  props: {
    id: {
      type: Number,
      required: true,
    },
    selectedGraphId: {
      type: Number,
      // Not required because we pass null
    },
    state: {
      type: String,
      required: true,
    },
    // start time in nanoseconds to start the graph
    // this allows multiple graphs to be synchronized
    startTime: {
      type: Number,
    },
    secondsGraphed: {
      type: Number,
      required: true,
    },
    pointsSaved: {
      type: Number,
      required: true,
    },
    pointsGraphed: {
      type: Number,
      required: true,
    },
    hideSystemBar: {
      type: Boolean,
      default: false,
    },
    hideOverview: {
      type: Boolean,
      default: false,
    },
    initialItems: {
      type: Array,
    },
    // These allow the parent to force a specific height and/or width
    height: {
      type: Number,
    },
    width: {
      type: Number,
    },
  },
  data() {
    return {
      itemHeaders: [
        { text: 'Target Name', value: 'targetName' },
        { text: 'Packet Name', value: 'packetName' },
        { text: 'Item Name', value: 'itemName' },
        { text: 'Actions', value: 'actions', sortable: false },
      ],
      valueTypes: ['CONVERTED', 'RAW'],
      active: true,
      expand: true,
      fullWidth: true,
      fullHeight: true,
      graph: null,
      editGraph: false,
      editGraphMenu: false,
      editGraphMenuX: 0,
      editGraphMenuY: 0,
      editItem: false,
      itemMenu: false,
      itemMenuX: 0,
      itemMenuY: 0,
      selectedItem: null,
      title: '',
      overview: null,
      data: [[]],
      graphMinY: '',
      graphMaxY: '',
      graphStartDateTime: this.startTime,
      graphEndDateTime: null,
      indexes: {},
      items: this.initialItems || [],
      drawInterval: null,
      zoomChart: false,
      zoomOverview: false,
      cable: new Cable(),
      subscription: null,
      needToUpdate: false,
      errorDialog: false,
      errors: [],
      colors: [
        'blue',
        'red',
        'green',
        'darkorange',
        'purple',
        'cornflowerblue',
        'lime',
        'gold',
        'hotpink',
        'tan',
        'cyan',
        'peru',
        'maroon',
        'coral',
        'navy',
        'teal',
        'brown',
        'crimson',
        'lightblue',
        'black',
      ],
    }
  },
  computed: {
    calcFullSize: function () {
      return this.fullWidth || this.fullHeight
    },
    editItems: function () {
      if (!this.items) return []
      let itemId = 0
      return this.items.map((item) => {
        itemId += 1
        return {...item, itemId}
      })
    },
    error: function () {
      if (this.errorDialog && this.errors.length > 0) {
        return JSON.stringify(this.errors, null, 4)
      }
      return null
    },
  },
  created() {
    this.title = `Graph ${this.id}`
    for (const [index, item] of this.items.entries()) {
      this.data.push([]) // initialize the empty data arrays
      this.indexes[this.subscriptionKey(item)] = index + 1
    }
  },
  mounted() {
    // This code allows for temporary pulling in a patched uPlot
    // Also note you need to add 'async' before the mounted method for await
    // const plugin = document.createElement('script')
    // plugin.setAttribute(
    //   'src',
    //   'https://leeoniya.github.io/uPlot/dist/uPlot.iife.min.js'
    // )
    // plugin.async = true
    // document.head.appendChild(plugin)
    // await new Promise(r => setTimeout(r, 500)) // Allow the js to load

    // TODO: This is demo / performance code of multiple items with many data points
    // 10 items at 500,000 each renders immediately and uses 180MB in Chrome
    // Refresh still works, chrome is sluggish but once you pause it is very performant
    // 500,000 pts at 1Hz is 138.9hrs .. almost 6 days
    //
    // 10 items at 100,000 each is very performant ... 1,000,000 pts is Qt TlmGrapher default
    // 100,000 pts at 1Hz is 27.8hrs
    //
    // 100,000 takes 40ms, Chrome uses 160MB
    // this.data = []
    // const dataPoints = 100000
    // const items = 10
    // let pts = new Array(dataPoints)
    // let times = new Array(dataPoints)
    // let time = 1589398007
    // let series = [{}]
    // for (let i = 0; i < dataPoints; i++) {
    //   times[i] = time
    //   pts[i] = i
    //   time += 1
    // }
    // this.data.push(times)
    // for (let i = 0; i < items; i++) {
    //   this.data.push(pts.map(x => x + i))
    //   series.push({
    //     label: 'Item' + i,
    //     stroke: this.colors[i]
    //   })
    // }

    const { chartSeries, overviewSeries } = this.items.reduce(
      (seriesObj, item) => {
        const commonProps = {
          spanGaps: true,
          stroke: this.colors.shift(),
        }
        seriesObj.chartSeries.push({
          ...commonProps,
          item: item,
          label: item.itemName,
          value: (self, rawValue) =>
            rawValue == null ? '--' : rawValue.toFixed(2),
        })
        seriesObj.overviewSeries.push({
          ...commonProps,
        })
        return seriesObj
      },
      { chartSeries: [], overviewSeries: [] }
    )

    let chartOpts = {
      ...this.getSize('chart'),
      ...this.getScales(),
      ...this.getAxes('chart'),
      // series: series, // TODO: Uncomment with the performance code
      series: [
        {
          label: 'Time',
          value: (u, v) =>
            // Convert the unix timestamp into a formatted date / time
            v == null ? '--' : format(toDate(v * 1000), 'yyyy-MM-dd HH:mm:ss'),
        },
        ...chartSeries,
      ],
      cursor: {
        drag: {
          x: true,
          y: false,
        },
        // Sync the cursor across graphs so mouseovers are synced
        sync: {
          key: 'cosmos',
          // setSeries links graphs so clicking an item to hide it also hides the other graph item
          // setSeries: true,
        },
      },
      hooks: {
        setScale: [
          (chart, key) => {
            if (key == 'x' && !this.zoomOverview && this.overview) {
              this.zoomChart = true
              let left = Math.round(
                this.overview.valToPos(chart.scales.x.min, 'x')
              )
              let right = Math.round(
                this.overview.valToPos(chart.scales.x.max, 'x')
              )
              this.overview.setSelect({ left, width: right - left })
              this.zoomChart = false
            }
          },
        ],
        ready: [
          (u) => {
            let clientX
            let clientY
            let canvas = u.root.querySelector('canvas')
            canvas.addEventListener('contextmenu', (e) => {
              e.preventDefault()
              this.editGraphMenuX = e.clientX
              this.editGraphMenuY = e.clientY
              this.editGraphMenu = true
            })
            let legend = u.root.querySelector('.u-legend')
            legend.addEventListener('contextmenu', (e) => {
              e.preventDefault()
              this.itemMenuX = e.clientX
              this.itemMenuY = e.clientY
              // Grab the closest series and then figure out which index it is
              let seriesEl = e.target.closest('.u-series')
              let seriesIdx = Array.prototype.slice
                .call(legend.childNodes)
                .indexOf(seriesEl)
              let series = u.series[seriesIdx]
              if (series.item) {
                this.selectedItem = series.item
                this.itemMenu = true
              }
              return false
            })
          },
        ],
      },
    }
    // console.time('chart')
    this.graph = new uPlot(
      chartOpts,
      this.data,
      document.getElementById(`chart${this.id}`)
    )

    const overviewOpts = {
      ...this.getSize('overview'),
      ...this.getScales(),
      ...this.getAxes('overview'),
      // series: series, // TODO: Uncomment with the performance code
      series: [...overviewSeries],
      cursor: {
        y: false,
        points: {
          show: false, // TODO: This isn't working
        },
        drag: {
          setScale: false,
          x: true,
          y: false,
        },
      },
      legend: {
        show: false,
      },
      hooks: {
        setSelect: [
          (chart) => {
            if (!this.zoomChart) {
              this.zoomOverview = true
              let min = chart.posToVal(chart.select.left, 'x')
              let max = chart.posToVal(
                chart.select.left + chart.select.width,
                'x'
              )
              this.graph.setScale('x', { min, max })
              this.zoomOverview = false
            }
          },
        ],
      },
    }
    this.overview = new uPlot(
      overviewOpts,
      this.data,
      document.getElementById(`overview${this.id}`)
    )
    //console.timeEnd('chart')

    // Allow the charts to dynamically resize when the window resizes
    window.addEventListener('resize', this.handleResize)

    if (this.state !== 'stop') {
      this.subscribe()
    }
  },
  beforeDestroy: function () {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    this.cable.disconnect()
    window.removeEventListener('resize', this.handleResize)
  },
  watch: {
    state: function (newState, oldState) {
      switch (newState) {
        case 'start':
          // Only subscribe if we were previously stopped
          // If we were paused we do nothing ... see the data function
          if (oldState === 'stop') {
            this.subscribe()
          }
          break
        // case 'pause': Nothing to do ... see the data function
        case 'stop':
          this.subscription.unsubscribe()
          this.subscription = null
          break
      }
    },
    data: function (newData, oldData) {
      // Ignore changes to the data while we're paused
      if (this.state === 'pause') {
        return
      }
      this.graph.setData(newData)
      this.overview.setData(newData)
      let max = newData[0][newData[0].length - 1]
      let ptsMin = newData[0][newData[0].length - this.pointsGraphed]
      let min = newData[0][0]
      if (min < max - this.secondsGraphed) {
        min = max - this.secondsGraphed
      }
      if (ptsMin > min) {
        min = ptsMin
      }
      this.graph.setScale('x', { min, max })
    },
    graphMinY: function (newVal, oldVal) {
      let val = parseFloat(newVal)
      if (!isNaN(val)) {
        this.graphMinY = val
      }
      this.setGraphRange()
    },
    graphMaxY: function (newVal, oldVal) {
      let val = parseFloat(newVal)
      if (!isNaN(val)) {
        this.graphMaxY = val
      }
      this.setGraphRange()
    },
    graphStartDateTime: function (val) {
      this.needToUpdate = true
      if (val && typeof val === 'string') {
        this.graphStartDateTime =
          new Date(this.graphStartDateTime).getTime() * 1_000_000
      }
    },
    graphEndDateTime: function (val) {
      this.needToUpdate = true
      if (val && typeof val === 'string') {
        this.graphEndDateTime =
          new Date(this.graphEndDateTime).getTime() * 1_000_000
      }
    },
  },
  methods: {
    clearErrors: function () {
      this.errors = []
    },
    editGraphClose: function () {
      this.editGraph = false
      if (this.needToUpdate) {
        this.removeItemsFromSubscription()
        this.addItemsToSubscription()
        this.needToUpdate = false
      }
    },
    handleResize: function () {
      // TODO: Should this method be throttled?
      this.graph.setSize(this.getSize('chart'))
      this.overview.setSize(this.getSize('overview'))
    },
    resize: function () {
      this.graph.setSize(this.getSize('chart'))
      this.overview.setSize(this.getSize('overview'))
      this.$emit('resize', this.id)
    },
    expandAll: function () {
      this.fullWidth = true
      this.fullHeight = true
      this.resize()
    },
    collapseAll: function () {
      this.fullWidth = false
      this.fullHeight = false
      this.resize()
    },
    expandWidth: function () {
      this.fullWidth = true
      this.resize()
    },
    collapseWidth: function () {
      this.fullWidth = false
      this.resize()
    },
    expandHeight: function () {
      this.fullHeight = true
      this.resize()
    },
    collapseHeight: function () {
      this.fullHeight = false
      this.resize()
    },
    minMaxTransition: function () {
      this.expand = !this.expand
      this.$emit('min-max-graph', this.id)
    },
    setGraphRange: function () {
      let pad = 0.1
      if (
        this.graphMinY ||
        this.graphMinY === 0 ||
        this.graphMaxY ||
        this.graphMaxY === 0
      ) {
        pad = 0
      }
      this.graph.scales.y.range = (u, dataMin, dataMax) => {
        let min = dataMin
        if (this.graphMinY || this.graphMinY === 0) {
          min = this.graphMinY
        }
        let max = dataMax
        if (this.graphMaxY || this.graphMaxY === 0) {
          max = this.graphMaxY
        }
        return uPlot.rangeNum(min, max, pad, true)
      }
    },
    subscribe: function (endTime = null) {
      this.cable
        .createSubscription('StreamingChannel', localStorage.scope, {
          received: (data) => this.received(data),
          connected: () => {
            this.addItemsToSubscription(this.items, endTime)
          },
        disconnected: () => {
          this.errors.push({
            type: 'disconnected',
            message: 'COSMOS backend connection disconnected',
            time: new Date().getTime()
          })
        },
        rejected: () => {
          this.errors.push({
            type: 'rejected',
            message: 'COSMOS backend connection rejected',
            time: new Date().getTime()
          })
        },
      })
      .then((subscription) => {
        this.subscription = subscription
      })
    },
    // throttle(cb, limit) {
    //   var wait = false
    //   return () => {
    //     if (!wait) {
    //       requestAnimationFrame(cb)
    //       wait = true
    //       setTimeout(() => {
    //         wait = false
    //       }, limit)
    //     }
    //   }
    // },
    getSize: function (type) {
      const navDrawer = document.getElementById('cosmos-nav-drawer')
      const navDrawerWidth = navDrawer.classList.contains(
        'v-navigation-drawer--open'
      )
        ? navDrawer.clientWidth
        : 0
      const viewWidth =
        Math.max(document.documentElement.clientWidth, window.innerWidth || 0) -
        navDrawerWidth
      const viewHeight = 
        Math.max(document.documentElement.clientHeight, window.innerHeight || 0)

      const chooser = document.getElementsByClassName('c-chooser')[0]
      let height = 100
      if (type === 'overview') {
        if (!this.fullHeight) {
          height = 0
        }
      } else if (chooser) {
        // Height of chart is viewportSize - chooser - overview - fudge factor (primarily padding)
        height = viewHeight - chooser.clientHeight - height - 190
        if (!this.fullHeight) {
          height = height / 2.0 + 10 // 5px padding top and bottom
        }
      }
      let width = viewWidth - 60 // 30px padding left and right
      if (!this.fullWidth) {
        width = width / 2.0 - 10 // 5px padding left and right
      }
      return {
        width: this.width || width,
        height: this.height || height,
      }
    },
    getScales: function () {
      return {
        scales: {
          x: {
            range(u, dataMin, dataMax) {
              if (dataMin == null) return [1566453600, 1566497660]
              return [dataMin, dataMax]
            },
          },
          y: {
            range(u, dataMin, dataMax) {
              if (dataMin == null) return [-100, 100]
              return uPlot.rangeNum(dataMin, dataMax, 0.1, true)
            },
          },
        },
      }
    },
    getAxes: function (type) {
      let strokeColor = 'rgba(0, 0, 0, .1)'
      let axisColor = 'black'
      if (this.$vuetify.theme.dark) {
        strokeColor = 'rgba(255, 255, 255, .1)'
        axisColor = 'white'
      }
      return {
        axes: [
          {
            stroke: axisColor,
            grid: {
              show: true,
              stroke: strokeColor,
              width: 2,
            },
          },
          {
            size: 70, // This size supports values up to 99 million
            stroke: axisColor,
            grid: {
              show: type === 'overview' ? false : true,
              stroke: strokeColor,
              width: 2,
            },
          },
        ],
      }
    },
    changeType: function (event) {
      this.removeItems([this.selectedItem])
      this.addItems([this.selectedItem], event)
    },
    addItems: function (itemArray, type = 'CONVERTED') {
      for (const item of itemArray) {
        item.valueType ||= type // set the default type
        this.items.push(item)
        const index = this.data.length
        const color = this.colors.shift()
        this.graph.addSeries(
          {
            spanGaps: true,
            item: item,
            label: item.itemName,
            stroke: color,
            value: (self, rawValue) =>
              rawValue == null ? '--' : rawValue.toFixed(2),
          },
          index
        )
        this.overview.addSeries({spanGaps: true, stroke: color}, index)
        let newData = Array(this.data[0].length)
        this.data.splice(index, 0, newData)
        this.indexes[this.subscriptionKey(item)] = index
      }
      this.addItemsToSubscription(itemArray)
    },
    addItemsToSubscription: function (
      itemArray = this.items,
      endTime = this.graphEndDateTime
    ) {
      if (this.subscription) {
        CosmosAuth.updateToken(CosmosAuth.defaultMinValidity).then(() => {
          this.subscription.perform('add', {
            scope: localStorage.scope,
            mode: 'DECOM',
            token: localStorage.token,
            items: itemArray.map(this.subscriptionKey),
            start_time: this.graphStartDateTime,
            end_time: endTime,
          })
        })
      }
    },
    removeItems: function (itemArray) {
      this.removeItemsFromSubscription(itemArray)

      for (const key of itemArray.map(this.subscriptionKey)) {
        const index = this.reorderIndexes(key)
        // Put back the color so it's available for new series
        this.colors.unshift(this.graph.series[index].stroke)
        this.items.splice(index - 1, 1)
        this.data.splice(index, 1)
        this.graph.delSeries(index)
        this.overview.delSeries(index)
        this.graph.setData(this.data)
        this.overview.setData(this.data)
      }
    },
    removeItemsFromSubscription: function (itemArray = this.items) {
      if (this.subscription) {
        this.subscription.perform('remove', {
          scope: localStorage.scope,
          items: itemArray.map(this.subscriptionKey),
        })
      }
    },
    reorderIndexes: function (key) {
      let index = this.indexes[key]
      delete this.indexes[key]
      for (var i in this.indexes) {
        if (this.indexes[i] > index) {
          this.indexes[i] -= 1
        }
      }
      return index
    },
    received: function (json_data) {
      // TODO: Shouldn't get errors but should we handle this every time?
      // if (json_data.error) {
      //   console.log(json_data.error)
      //   return
      // }
      let data = JSON.parse(json_data)
      for (let i = 0; i < data.length; i++) {
        let time = data[i].time / 1_000_000_000.0 // Time in seconds
        let length = data[0].length
        if (length == 0 || time > data[0][length - 1]) {
          // Nominal case - append new data to end
          for (let j = 0; j < this.data.length; j++) {
            this.data[j].push(null)
          }
          this.set_data_at_index(this.data[0].length - 1, time, data[i])
        } else {
          let index = bs(this.data[0], time, this.bs_comparator)
          if (index >= 0) {
            // Found the slot in the existing data
            this.set_data_at_index(index, time, data[i])
          } else {
            // Insert a new null slot at the ideal index
            let ideal_index = -index - 1
            for (let j = 0; j < this.data.length; j++) {
              this.data[j].splice(ideal_index, 0, null)
            }
            this.set_data_at_index(ideal_index, time, data[i])
          }
        }
      }
      // If we weren't passed a startTime notify grapher of our start
      if (this.startTime === null) {
        this.graphStartDateTime = this.data[0][0] * 1_000_000_000
        this.$emit('started', this.graphStartDateTime)
      }
    },
    bs_comparator: function (element, needle) {
      return element - needle
    },
    set_data_at_index: function (index, time, new_data) {
      this.data[0][index] = time
      for (const [key, value] of Object.entries(new_data)) {
        if (key == 'time') {
          continue
        }
        let key_index = this.indexes[key]
        if (key_index) {
          let array = this.data[key_index]
          if (!value.raw) {
            array[index] = value
          } else {
            array[index] = null
          }
        }
      }
    },
    subscriptionKey: function (item) {
      return `TLM__${item.targetName}__${item.packetName}__${item.itemName}__${item.valueType}`
    },
  },
}
</script>

<style scoped>
#chart {
  background-color: var(--v-tertiary-darken2);
}
#chart >>> .u-legend {
  text-align: left;
}
#chart >>> .u-inline {
  max-width: fit-content;
}
/* TODO: Get this to work with white theme, values would be 0 in white */
#chart >>> .u-select {
  background-color: rgba(255, 255, 255, 0.07);
}
</style>
