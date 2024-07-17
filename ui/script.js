
const App = Vue.createApp({
    data() {
        return {
            data: {},
            locales: {},
            page: "home",
            boost: "normal",
            showSettings: false,
            showUI: false,
            showMinimap: true
        };
    },
    methods: {
        fetchData(key, value) {
            fetch(`https://${GetParentResourceName()}/getData`, {
                method: 'POST',
                body: JSON.stringify({
                    action: key,
                    data: value
                })
            });
        },
        close() {
            fetch(`https://${GetParentResourceName()}/exit`);
            this.showSettings = false
            this.showUI = false
        },
        changes(event) {
            let inputValue = event.target.value
            let checked = event.target.checked
            this.showMinimap = checked
            this.fetchData('settings', {state: checked, inputValue: inputValue})
        },
        copyID() {
            this.fetchData('copyID', {identifier: this.data.license})
        },
        handleKeyDown(event) {
            if (event.key === "Escape" || event.key === "Home") {
                this.close();
            }
        },
        switchpage(newPage) {
            this.showSettings = newPage === "settings"
        },
    },

    mounted() {
        this.showMinimap = true

        window.addEventListener('message', (event) => {
            if (event.data.type === "show") {
                this.showUI = event.data.enable;
            } else if (event.data.type === "loadData") {
                this.data = event.data.data;
                this.locales = event.data.locales;
            }
        });

        window.addEventListener('keydown', this.handleKeyDown);

    }
}).mount('#app');