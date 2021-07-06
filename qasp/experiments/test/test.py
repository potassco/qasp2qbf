#!/usr/bin/python
import unittest
from compare import solve_qasp, solve_ascp

CONF="../all_conformant/"
COND="./"

class TestConformant(unittest.TestCase):
    def test_bt(self):
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=3 -c h=3"),
            solve_ascp(CONF+"bt.ascp.lp -c p=3 -c h=3"))

    def test_bmt(self):
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=2 -c h=1 -c t=2 "),[])
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=2 -c h=2 -c t=2 "),
            solve_ascp(CONF+"bt.ascp.lp -c p=2 -c h=2 -c t=2"))
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=4 -c h=4 -c t=2 "),
            solve_ascp(CONF+"bt.ascp.lp -c p=4 -c h=4 -c t=2"))

    def test_btc(self):
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=2 -c h=2 -c clogging=1"),[])
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=4 -c h=7 -c clogging=1"),
            solve_ascp(CONF+"bt.ascp.lp -c p=4 -c h=7 -c clogging=1"))

    def test_bmtc(self):
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=3 -c h=2 -c clogging=1 -c t=2"),[])
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=4 -c h=6 -c clogging=1 -c t=2"),
            solve_ascp(CONF+"bt.ascp.lp -c p=4 -c h=6 -c clogging=1 -c t=2"))

    def test_btuc(self):
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=2 -c h=4 -c clogging=1 -c unknown_clogging=1"),
            solve_ascp(CONF+"bt.ascp.lp -c p=2 -c h=4 -c clogging=1 -c unknown_clogging=1"))
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=2 -c h=2 -c clogging=1 -c unknown_clogging=1"),
            [])

    def test_bmtuc(self):
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"bt.qasp.lp -c p=2 -c h=2 -c clogging=1 -c unknown_clogging=1 -c t=2"),
            solve_ascp(CONF+"bt.ascp.lp -c p=2 -c h=2 -c clogging=1 -c unknown_clogging=1 -c t=2"))

    def test_domino(self):
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"domino.qasp.lp -c d=10 -c h=1"),
            solve_ascp(CONF+"domino.ascp.lp -c p=10 -c h=1"))

    def test_ring(self):
        self.assertNotEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"ring.qasp.lp -c r=2 -c h=5"), [])
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"ring.qasp.lp -c r=2 -c h=5"),
            solve_ascp(CONF+"ring.ascp.lp -c r=2 -c h=5"))
        self.assertEqual(
            solve_qasp(CONF+"meta.lp "+CONF+"conformant.lp "+CONF+"ring.qasp.lp -c r=4 -c h=11"),
            solve_ascp(CONF+"ring.ascp.lp -c r=4 -c h=11"))

#class TestConditional(unittest.TestCase):

if __name__ == '__main__':
    unittest.main()
