// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2022 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2022 Ilias Khairullin <ilias@nil.foundation>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//---------------------------------------------------------------------------//
pragma solidity >=0.8.4;

import '../../types.sol';
import '../../cryptography/transcript.sol';
import '../proof_map_parser.sol';
import '../verifier_poseidon_component.sol';

contract TestRedshiftVerifierPoseidon {
    types.lpc_params_type lpc_params;
    types.redshift_common_data common_data;

    function set_initial_params(
        uint256 modulus,
        uint256 r,
        uint256 max_degree,
        uint256 lambda,
        uint256 m,
        uint256 rows_amount,
        uint256 omega,
        uint256 columns_number
    ) public {
        lpc_params.modulus = modulus;
        lpc_params.lambda = lambda;
        lpc_params.r = r;
        lpc_params.m = m;

        lpc_params.fri_params.modulus = modulus;
        lpc_params.fri_params.r = r;
        lpc_params.fri_params.max_degree = max_degree;

        common_data.rows_amount = rows_amount;
        common_data.omega = omega;
        common_data.columns_rotations = new int256[][](columns_number);
    }

    function set_U(uint256[] calldata U) public {
        lpc_params.fri_params.U = U;
    }

    function set_V(uint256[] calldata V) public {
        lpc_params.fri_params.V = V;
    }

    function set_D_omegas(uint256[] calldata D_omegas) public {
        lpc_params.fri_params.D_omegas = D_omegas;
    }

    function set_q(uint256[] calldata q) public {
        lpc_params.fri_params.q = q;
    }

    function set_column_rotations(int256[] calldata rotations, uint256 i) public {
        common_data.columns_rotations[i] = rotations;
    }

    function verify(bytes calldata blob) public view {
        (types.redshift_proof_map memory proof_map, uint256 proof_size) = redshift_proof_map_parser.parse_be(blob, 0);
        require(proof_size == blob.length, "Proof length was detected incorrectly!");
        bytes memory init_blob = hex"";
        types.transcript_data memory tr_state;
        transcript.init_transcript(tr_state, init_blob);
        bool result = redshift_verifier_poseidon_component.parse_verify_proof_be(blob, 0, tr_state, proof_map, lpc_params, common_data);
        require(result, "Proof is not correct!");
    }
}