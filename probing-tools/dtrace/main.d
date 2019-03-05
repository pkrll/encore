#pragma D option quiet

#define DOPRINT 0
#define ACTORMSG_BLOCK (4294967295 - 6)   // 4294967289
#define ACTORMSG_UNBLOCK (4294967295 - 5) // 4294967290
#define ACTORMSG_ACQUIRE (4294967295 - 4) // 4294967291
#define ACTORMSG_RELEASE (4294967295 - 3) // 4294967292
#define ACTORMSG_CONF (4294967295 - 2)  	// 4294967293
#define ACTORMSG_ACK (4294967295 - 1) 		// 4294967294

int did_run_probe[string];

pony$target:::actor-alloc {
	#if defined(DOPRINT) && DOPRINT == 1
    printf("Actor alloc on scheduler %d (cpu: %d)\n", arg0, cpu);
  #endif
}

pony$target::: /did_run_probe[probename] != 1/ {
  did_run_probe[probename] = 1;
}

encore$target::: /did_run_probe[probename] != 1/ {
  did_run_probe[probename] = 1;
}

pony$target:::actor-msg-send {
  @counter[probename] = count();
}

encore$target:::future-create {
  @counter[probename] = count();
  // Used for lifetime of a future
  future_create_starttime[arg1] = timestamp;
}

encore$target:::future-block {
  @counter[probename]   = count();
  @future_block[arg1] = count();
  @actor_blocked[arg0]  = count();
  @future_blocked_actor[arg1, arg0] = count();
  // Used for duration of a block
  future_block_starttime[arg1] = timestamp;
}

encore$target:::future-unblock {
  @counter[probename] = count();
  @future_block_lifetime[arg1] = sum(timestamp - future_block_starttime[arg1]);
}

encore$target:::future-chaining {
  @counter[probename] = count();
  @future_chaining[arg1] = count();
}

encore$target:::future-fulfil-start {
  @counter[probename] = count();
}

encore$target:::future-fulfil-end {
  @counter[probename] = count();
}

encore$target:::future-get {
  @counter[probename] = count();
}

encore$target:::future-destroy {
  @counter[probename] = count();
  @future_lifetime[arg1] = sum(timestamp - future_create_starttime[arg1]);
}

END {
  printf("=== FUTURE INFORMATION ===\n");
  printf("=== COUNTS ===\n");
  printa("%s\t%@1u\n", @counter);

	if (did_run_probe["future-create"]) {
	  printf("\n=== FUTURE_LIFETIME ===\n");
	  printf("Future Addr\t\tLifetime (nanoseconds)\n");
	  printa("%d\t\t%@1u\n", @future_lifetime);
	}
	if (did_run_probe["future-block"]) {
	  printf("\n=== FUTURE_BLOCKED_LIFETIME ===\n");
	  printf("Future Addr\t\tLifetime (nanoseconds)\n");
	  printa("%d\t\t%@1u\n", @future_block_lifetime);

  	printf("\n=== FUTURE_BLOCKED_ACTOR ===\n");
  	printf("Future Addr\t\tActor addr\t\tLifetime (nanoseconds)\n");
  	printa("%d\t\t%d\t\t%@2u\n", @future_blocked_actor);

	  printf("\n=== NUMBER OF TIMES AN ACTOR IS BLOCKED ===\n");
	  printf("Actor Addr\t\tCount\n");
	  printa("%d\t\t%@2u\n", @actor_blocked);

		printf("\n=== NUMBER OF TIMES A FUTURE BLOCKS ===\n");
	  printf("Future Addr\t\tCount\n");
	  printa("%d\t\t%@2u\n", @future_block);
	}

	if (did_run_probe["future-chaining"]) {
	  printf("\n=== NUMBER OF TIMES A FUTURE IS CHAINED ===\n");
	  printf("Future Addr\t\tCount\n");
	  printa("%d\t\t%@2u\n", @future_chaining);
	}
}
