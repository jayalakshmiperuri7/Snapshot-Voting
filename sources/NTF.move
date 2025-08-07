module jayalakshmi_addr::SnapshotVoting {
    use aptos_framework::signer;
    use std::vector;
    
    /// Struct representing a voting proposal with snapshot verification
    struct Proposal has store, key {
        title: vector<u8>,           // Proposal title
        snapshot_hash: vector<u8>,   // Hash of off-chain voting snapshot
        total_votes: u64,            // Total number of votes cast
        is_verified: bool,           // Whether the snapshot has been verified on-chain
        creator: address,            // Address of the proposal creator
    }
    
    /// Error codes
    const E_PROPOSAL_NOT_FOUND: u64 = 1;
    const E_ALREADY_VERIFIED: u64 = 2;
    const E_UNAUTHORIZED: u64 = 3;
    
    /// Function to create a new voting proposal with snapshot data
    public fun create_proposal(
        creator: &signer, 
        title: vector<u8>, 
        snapshot_hash: vector<u8>
    ) {
        let creator_addr = signer::address_of(creator);
        let proposal = Proposal {
            title,
            snapshot_hash,
            total_votes: 0,
            is_verified: false,
            creator: creator_addr,
        };
        move_to(creator, proposal);
    }
    
    /// Function to verify off-chain voting results on-chain
    public fun verify_snapshot(
        verifier: &signer, 
        proposal_owner: address, 
        vote_count: u64,
        provided_hash: vector<u8>
    ) acquires Proposal {
        let verifier_addr = signer::address_of(verifier);
        let proposal = borrow_global_mut<Proposal>(proposal_owner);
        
        // Only the creator can verify their own proposal
        assert!(proposal.creator == verifier_addr, E_UNAUTHORIZED);
        
        // Check if already verified
        assert!(!proposal.is_verified, E_ALREADY_VERIFIED);
        
        // Verify the snapshot hash matches
        assert!(proposal.snapshot_hash == provided_hash, E_PROPOSAL_NOT_FOUND);
        
        // Update proposal with verified vote count
        proposal.total_votes = vote_count;
        proposal.is_verified = true;
    }
}