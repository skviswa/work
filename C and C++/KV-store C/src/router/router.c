#include <stdio.h>
#include<string.h>
#include<stdlib.h>
#include <protobuf-c/protobuf-c.h>
#include <protobuf-c-rpc/protobuf-c-rpc.h>
#include <protobuf/protocol.pb-c.h>
#include "hash_ring.h"

struct servers {
	char address_port[20];
	int hashid;
	struct servers *next;
	struct servers *prev;
};
hash_ring_t *ring;
void setup_hash_ring()
{
	ring = hash_ring_create(2, HASH_FUNCTION_SHA1);
	char *slotA = "127.0.0.1:3000";
	char *slotB = "127.0.0.1:5677";
	char *slotC = "127.0.0.1:7890";
	char *slotD = "127.0.0.1:8897";

	assert(hash_ring_add_node(ring, (uint8_t*)slotA, strlen(slotA)) == HASH_RING_OK);
	assert(hash_ring_add_node(ring, (uint8_t*)slotB, strlen(slotB)) == HASH_RING_OK);
	assert(hash_ring_add_node(ring, (uint8_t*)slotC, strlen(slotC)) == HASH_RING_OK);
	assert(hash_ring_add_node(ring, (uint8_t*)slotD, strlen(slotD)) == HASH_RING_OK);

}
static void
lookup__get_server (Dkvs__Router_Service    *service,
                  const Dkvs__RouterRequest   *getaddress,
				  Dkvs__RouterResponse_Closure  closure,
                  void                      *closure_data)
{
    printf ("router Got get address Request \n");

  (void) service;
	hash_ring_node_t *node;
  if (getaddress == NULL)
  {
	  printf("Request null\n");
    closure (NULL, closure_data);
  }
  else
  {
		Dkvs__RouterResponse result = DKVS__ROUTER_RESPONSE__INIT;
		result.address=malloc(20);
		//strcpy(result.address,address) ;
		node = hash_ring_find_node(ring, (uint8_t*)(getaddress->key.data), strlen(getaddress->key.data));
		printf("server %s\n",node->name);
		strcpy(result.address,node->name) ;
		closure (&result, closure_data);
   }
  hash_ring_print(ring);
}

static Dkvs__Router_Service router_service =
	 DKVS__ROUTER__INIT(lookup__);

int main(int argc, char**argv) {
	setup_hash_ring();
	ProtobufC_RPC_Server *server;
	ProtobufC_RPC_AddressType address_type=0;
	address_type = PROTOBUF_C_RPC_ADDRESS_TCP;
	const char *name = NULL;
	name = argv[1];
	server = protobuf_c_rpc_server_new (address_type, name, (ProtobufCService *) &router_service, NULL);
	 for (;;)
	    protobuf_c_rpc_dispatch_run (protobuf_c_rpc_dispatch_default ());


	hash_ring_free(ring);
	return 0;
}
