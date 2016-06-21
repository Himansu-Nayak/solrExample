package com.org;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.impl.HttpSolrServer;

public final class SolrServerFactory {
    Map<String, SolrServer> urlToServer = new ConcurrentHashMap<String, SolrServer>();
    static SolrServerFactory instance = new SolrServerFactory();

    public static SolrServerFactory getInstance() {
        return instance;
    }

    private SolrServerFactory() {
    }

    public SolrServer createServer(String solrURL) {
        if (urlToServer.containsKey(solrURL))
            return urlToServer.get(solrURL);

        /*
         * HttpSolrServer is thread-safe and if you are using the following constructor, you *MUST* re-use the same
         * instance for all requests. If instances are created on the fly, it can cause a connection leak. The
         * recommended practice is to keep a static instance of HttpSolrServer per solr server url and share it for all
         * requests. See https://issues.apache.org/jira/browse/SOLR-861 for more details
         */
        SolrServer server = new HttpSolrServer(solrURL);
        urlToServer.put(solrURL, server);
        return server;
    }
}