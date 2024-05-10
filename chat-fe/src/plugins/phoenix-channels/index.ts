import NetClient from "../../lib/socket";

const VueChannel = {

    install(Vue, options) {
        const { url, params, store } = options;
        if (!url) throw new Error("[VueChannel] Cannot connect to an empty URL")

        // let observer = new Observer(connection, params, store)


        Vue.config.globalProperties.$netClient = new NetClient(url,store);
    }

}

export default VueChannel;