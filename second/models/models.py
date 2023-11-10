-*- coding: utf-8 -*-

from odoo import models, fields, api

class g(models.Model):
    _inherit = 'res.partner'


    @api.model_create_multi
    def create(self, vals_list):
        res = super().create(vals_list)
        for r in res:
            r.name = '****' + res.name + '****'
        return res
    