from odoo.tests import TransactionCase, tagged
from odoo.exceptions import ValidationError



@tagged('post_install', '-at_install')
class TestExpenseApproval(TransactionCase):

    def setUp(self):
        super(TestExpenseApproval, self).setUp()
        self.unit = self.env['res.partner'].create({
            'name': 'CBM',
        })

    def test_create_partner(self):
        # self.assertEqual(self.unit.name, 'CBM')
        self.assertEqual(self.unit.name, '*CBM*')