from odoo import models, fields


class ResCompany(models.Model):
    _inherit = 'res.company'

    web_title = fields.Char(string='Web Title')
