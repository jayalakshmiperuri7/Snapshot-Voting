module jayalakshmi_addr::SnapshotVoting {
    use aptos_framework::signer;
    use std::vector;
    

    struct Proposal has store, key {
        title: vector<u8>,           
        snapshot_hash: vector<u8>,   
        total_votes: u64,            
        is_verified: bool,          
        creator: address,           
    }
    
    
    const E_PROPOSAL_NOT_FOUND: u64 = 1;
    const E_ALREADY_VERIFIED: u64 = 2;
    const E_UNAUTHORIZED: u64 = 3;
    

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
    

    public fun verify_snapshot(
        verifier: &signer, 
        proposal_owner: address, 
        vote_count: u64,
        provided_hash: vector<u8>
    ) acquires Proposal {
        let verifier_addr = signer::address_of(verifier);
        let proposal = borrow_global_mut<Proposal>(proposal_owner);
        
        
        assert!(proposal.creator == verifier_addr, E_UNAUTHORIZED);
        
        
        assert!(!proposal.is_verified, E_ALREADY_VERIFIED);
        
        assert!(proposal.snapshot_hash == provided_hash, E_PROPOSAL_NOT_FOUND);
        
        
        proposal.total_votes = vote_count;
        proposal.is_verified = true;
    }

}
