# -*- coding: utf-8 -*-

from odoo import models, fields, api


class f(models.Model):
    _inherit = 'res.partner'

    phone = fields.Char(string='oh yeah - o_o -o-')