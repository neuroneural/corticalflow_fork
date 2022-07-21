
""" Test the implementation of Chamfer loss + curvature """

__author__ = "Fabi Bongratz"
__email__ = "fabi.bongratz@gmail.com"

import unittest

import torch

from pytorch3d.structures import Meshes
from pytorch3d.utils import ico_sphere
from pytorch3d.loss.chamfer import chamfer_distance
from pytorch3d.ops import cot_laplacian

class TestChamferCurvature(unittest.TestCase):
    def setUp(self):
        self.mesh1 = ico_sphere(level=1)
        self.mesh2 = Meshes(self.mesh1.verts_padded() + 0.01,
                            self.mesh1.faces_padded())

    def test_curvature_comparison(self):
        curv= []

        for m in (self.mesh1, self.mesh2):
            verts_packed, faces_packed = m.verts_packed(), m.faces_packed()
            L, inv_areas = cot_laplacian(verts_packed, faces_packed)
            L_sum = torch.sparse.sum(L, dim=1).to_dense().view(-1,1)
            norm_w = 0.25 * inv_areas

            curv.append(torch.norm(
                (L.mm(verts_packed) - L_sum * verts_packed) * norm_w,
                dim=1
            ))

        d, _, d_curv = chamfer_distance(self.mesh1.verts_padded(),
                                        self.mesh2.verts_padded(),
                                        x_curvatures=curv[0].unsqueeze(0).unsqueeze(-1),
                                        y_curvatures=curv[1].unsqueeze(0).unsqueeze(-1))

        print("Chamfer: ", str(d))
        print("Difference in curvature: ", str(d_curv))

        self.assertTrue(torch.allclose(d_curv, torch.tensor(0.0), atol=1e-6))

    def test_curvature_weights(self):

        verts_packed, faces_packed = self.mesh2.verts_packed(), self.mesh2.faces_packed()
        L, inv_areas = cot_laplacian(verts_packed, faces_packed)
        L_sum = torch.sparse.sum(L, dim=1).to_dense().view(-1,1)
        norm_w = 0.25 * inv_areas

        curv = torch.norm(
            (L.mm(verts_packed) - L_sum* verts_packed) * norm_w,
            dim=1
        )

        d, _, _ = chamfer_distance(self.mesh1.verts_padded(), self.mesh2.verts_padded(),
                                   point_weights = 1 + curv)

        print("Chamfer: ", str(d))
