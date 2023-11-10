# -*- coding: utf-8 -*-

from odoo import models, fields, api


class f(models.Model):
    _inherit = 'res.partner'

    phone = fields.Char(string='she will have taken the medicine to the hospitala')