<template>
  <view class="container">
    <view class="header">
      <text class="title">IDWise Plugin Test</text>
    </view>

    <view class="section">
      <text class="label">SDK Status:</text>
      <text class="status" :class="{ 'status-success': sdkInitialized }">
        {{ sdkStatus }}
      </text>
    </view>

    <view class="section">
      <text class="label">Client Key:</text>
      <input
        class="input"
        v-model="clientKey"
        placeholder="Enter Client Key"
        type="text"
      />
    </view>

    <view class="section">
      <text class="label">Flow ID:</text>
      <input
        class="input"
        v-model="flowId"
        placeholder="Enter Flow ID"
        type="text"
      />
    </view>

    <view class="section">
      <text class="label">Reference Number:</text>
      <input
        class="input"
        v-model="referenceNumber"
        placeholder="Reference Number (optional)"
        type="text"
      />
    </view>

    <view class="section">
      <text class="label">Theme:</text>
      <radio-group @change="onThemeChange">
        <label v-for="theme in themes" :key="theme" class="radio-item">
          <radio :value="theme" :checked="selectedTheme === theme" />
          <text>{{ theme }}</text>
        </label>
      </radio-group>
    </view>

    <view class="button-section">
      <button
        class="btn btn-primary"
        @click="initializeAndStartJourney"
      >
        Start Journey
      </button>

      <button
        class="btn btn-info"
        @click="resumeJourney"
      >
        Resume Journey
      </button>

      <button
        class="btn btn-warning"
        @click="checkDeviceBlocked"
      >
        Check Device Blocked
      </button>
    </view>

    <view class="log-section">
      <text class="log-title">Event Log:</text>
      <scroll-view class="log-content" scroll-y="true">
        <text
          v-for="(log, index) in eventLogs"
          :key="index"
          class="log-item"
        >
          {{ log }}
        </text>
      </scroll-view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      IDWise: null,
      sdkInitialized: false,
      sdkStatus: 'Not Initialized',
      clientKey: '',
      flowId: '',
      referenceNumber: '',
      journeyId: '',
      themes: ['system_default', 'light', 'dark'],
      selectedTheme: 'system_default',
      eventLogs: []
    };
  },
  onLoad() {
    // Load the native plugin
    // IMPORTANT: Use module name from package.json (line 13)
    this.IDWise = uni.requireNativePlugin('idwise-uni-plugin');
    this.addLog('Plugin loaded');
    this.addLog('IDWise module: ' + JSON.stringify(this.IDWise));
  },
  methods: {
    addLog(message) {
      const timestamp = new Date().toLocaleTimeString();
      this.eventLogs.push(`[${timestamp}] ${message}`);
    },

    onThemeChange(e) {
      this.selectedTheme = e.detail.value;
      this.addLog(`Theme changed to: ${this.selectedTheme}`);
    },

    initializeAndStartJourney() {
      if (!this.IDWise) {
        uni.showToast({
          title: 'Plugin not loaded',
          icon: 'error'
        });
        this.addLog('ERROR: IDWise plugin not loaded');
        return;
      }

      if (!this.clientKey) {
        uni.showToast({
          title: 'Please enter Client Key',
          icon: 'none'
        });
        return;
      }

      if (!this.flowId) {
        uni.showToast({
          title: 'Please enter Flow ID',
          icon: 'none'
        });
        return;
      }

      this.addLog('Initializing SDK...');
      this.addLog('Available methods: ' + Object.keys(this.IDWise).join(', '));

      const initOptions = {
        clientKey: this.clientKey,
        theme: this.selectedTheme
      };

      if (typeof this.IDWise.initialize !== 'function') {
        this.addLog('ERROR: initialize is not a function. Type: ' + typeof this.IDWise.initialize);
        uni.showToast({
          title: 'initialize method not found',
          icon: 'error'
        });
        return;
      }

      this.IDWise.initialize(initOptions, (result) => {
        this.addLog(`Initialize result: ${JSON.stringify(result)}`);

        if (result.success) {
          this.sdkStatus = 'Initialized';
          this.sdkInitialized = true;
          this.addLog('SDK Initialized successfully, starting journey...');

          // Start journey immediately after successful initialization
          const journeyOptions = {
            flowId: this.flowId,
            referenceNumber: this.referenceNumber || '',
            locale: 'en'
          };

          this.IDWise.startJourney(journeyOptions, (journeyResult) => {
            this.addLog(`Journey event: ${JSON.stringify(journeyResult)}`);

            if (journeyResult.event === 'onJourneyStarted') {
              this.journeyId = journeyResult.data.journeyId;
              uni.showToast({
                title: 'Journey Started',
                icon: 'success'
              });
            } else if (journeyResult.event === 'onJourneyCompleted') {
              uni.showToast({
                title: journeyResult.data.isSuccessful ? 'Journey Completed' : 'Journey Failed',
                icon: journeyResult.data.isSuccessful ? 'success' : 'error'
              });
            } else if (journeyResult.event === 'onJourneyCancelled') {
              uni.showToast({
                title: 'Journey Cancelled',
                icon: 'none'
              });
            } else if (journeyResult.event === 'onError') {
              uni.showToast({
                title: journeyResult.data.message || 'Error occurred',
                icon: 'error'
              });
            }
          });
        } else {
          this.sdkStatus = 'Initialization Failed';
          const errorMessage = result.error && result.error.message ? result.error.message : 'Initialization failed';
          uni.showToast({
            title: errorMessage,
            icon: 'error'
          });
        }
      });
    },

    resumeJourney() {
      if (!this.IDWise) {
        uni.showToast({
          title: 'Plugin not loaded',
          icon: 'error'
        });
        this.addLog('ERROR: IDWise plugin not loaded');
        return;
      }

      if (!this.clientKey) {
        uni.showToast({
          title: 'Please enter Client Key',
          icon: 'none'
        });
        return;
      }

      if (!this.flowId) {
        uni.showToast({
          title: 'Please enter Flow ID',
          icon: 'none'
        });
        return;
      }

      if (!this.journeyId) {
        uni.showToast({
          title: 'No Journey ID available. Start a journey first.',
          icon: 'none'
        });
        return;
      }

      this.addLog('Initializing SDK before resuming journey...');

      const initOptions = {
        clientKey: this.clientKey,
        theme: this.selectedTheme
      };

      this.IDWise.initialize(initOptions, (result) => {
        this.addLog(`Initialize result: ${JSON.stringify(result)}`);

        if (result.success) {
          this.sdkStatus = 'Initialized';
          this.sdkInitialized = true;
          this.addLog('SDK Initialized successfully, resuming journey...');

          const options = {
            flowId: this.flowId,
            journeyId: this.journeyId,
            locale: 'en'
          };

          this.IDWise.resumeJourney(options, (journeyResult) => {
            this.addLog(`Journey event: ${JSON.stringify(journeyResult)}`);

            if (journeyResult.event === 'onJourneyResumed') {
              uni.showToast({
                title: 'Journey Resumed',
                icon: 'success'
              });
            } else if (journeyResult.event === 'onJourneyCompleted') {
              uni.showToast({
                title: journeyResult.data.isSuccessful ? 'Journey Completed' : 'Journey Failed',
                icon: journeyResult.data.isSuccessful ? 'success' : 'error'
              });
            } else if (journeyResult.event === 'onJourneyCancelled') {
              uni.showToast({
                title: 'Journey Cancelled',
                icon: 'none'
              });
            } else if (journeyResult.event === 'onError') {
              uni.showToast({
                title: journeyResult.data.message || 'Error occurred',
                icon: 'error'
              });
            }
          });
        } else {
          this.sdkStatus = 'Initialization Failed';
          const errorMessage = result.error && result.error.message ? result.error.message : 'Initialization failed';
          uni.showToast({
            title: errorMessage,
            icon: 'error'
          });
          this.addLog('ERROR: Failed to initialize SDK before resuming');
        }
      });
    },

    checkDeviceBlocked() {
      this.addLog('Checking if device is blocked...');

      const isBlocked = this.IDWise.isDeviceBlocked();

      this.addLog(`Device blocked status: ${isBlocked}`);
      uni.showToast({
        title: isBlocked ? 'Device is Blocked' : 'Device is Not Blocked',
        icon: isBlocked ? 'none' : 'success'
      });
    }
  }
};
</script>

<style scoped>
.container {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.header {
  margin-bottom: 20px;
  text-align: center;
}

.title {
  font-size: 24px;
  font-weight: bold;
  color: #333;
}

.section {
  margin-bottom: 15px;
  background-color: white;
  padding: 15px;
  border-radius: 8px;
}

.label {
  font-size: 14px;
  color: #666;
  margin-bottom: 5px;
  display: block;
}

.status {
  font-size: 16px;
  color: #ff6600;
  font-weight: bold;
}

.status-success {
  color: #09bb07;
}

.input {
  width: 100%;
  height: 40px;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 0 10px;
  font-size: 14px;
  margin-top: 5px;
}

.radio-item {
  display: flex;
  align-items: center;
  margin: 8px 0;
}

.radio-item text {
  margin-left: 8px;
}

.button-section {
  margin: 20px 0;
}

.btn {
  width: 100%;
  margin-bottom: 10px;
  border-radius: 4px;
  font-size: 16px;
}

.btn-primary {
  background-color: #007aff;
  color: white;
}

.btn-success {
  background-color: #09bb07;
  color: white;
}

.btn-info {
  background-color: #10aeff;
  color: white;
}

.btn-warning {
  background-color: #ff6600;
  color: white;
}

.log-section {
  background-color: white;
  padding: 15px;
  border-radius: 8px;
  margin-top: 20px;
}

.log-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
  display: block;
}

.log-content {
  height: 200px;
  background-color: #f9f9f9;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 10px;
}

.log-item {
  font-size: 12px;
  color: #666;
  line-height: 20px;
  display: block;
  margin-bottom: 5px;
  font-family: monospace;
}
</style>
