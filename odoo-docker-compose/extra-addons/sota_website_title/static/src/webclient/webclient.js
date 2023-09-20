/** @odoo-module **/

import {WebClient} from "@web/webclient/webclient";
import {patch} from "web.utils";
import {useService} from "@web/core/utils/hooks";
import {session} from "@web/session";

patch(WebClient.prototype, "scs_website_title.WebClient", {
    setup() {
        this._super();
        useService("orm").read("res.company", [session.company_id], ['web_title']).then((res) => {
            if (res[0].web_title) this.title.setParts({zopenerp: res[0].web_title});
        })
    }
});
