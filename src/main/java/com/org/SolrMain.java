package com.org;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import com.org.entity.Item;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.common.SolrInputDocument;

public class SolrMain {
    String solrURL = "http://localhost:8983/solr/collection";

    public static void main(String...args) {
        new SolrMain().execute();
    }

    public void execute() {
        System.out.println("Starting off " + this.getClass().toString());
        SolrDao<Item> solrDao = new SolrDao<Item>(solrURL);

        addDocuments(solrDao);
        readDocuments(solrDao);

        addItems(solrDao);
        readItems(solrDao);
    }

    private void readItems(SolrDao<Item> solrDao) {
        QueryResponse rsp = solrDao.readAll();
        SolrDocumentList beans = rsp.getResults();
        System.out.println(beans);

        for (int i = 0; i < beans.size(); i++) {
            SolrDocument item = beans.get(i);
            System.out.println(item);
        }
    }

    private void addItems(SolrDao<Item> solrDao) {
        Collection<Item> items = new ArrayList<Item>(3);
        items.add(new Item("1", "Item 1", 20));
        items.add(new Item("2", "Item 2", 10));
        items.add(new Item("3", "Item 3", 30));
        solrDao.put(items);
    }

    private void readDocuments(SolrDao<Item> solrDao) {
        SolrDocumentList docs = solrDao.readAllDocs();
        Iterator<SolrDocument> iter = docs.iterator();
        int count = 10;

        while (iter.hasNext() && count-- > 0) {
            SolrDocument resultDoc = iter.next();

            String content = (String) resultDoc.getFieldValue("content");
            String id = (String) resultDoc.getFieldValue("id"); //id is the uniqueKey field
            System.out.println("Read " + resultDoc + " with id = " + id + " and content = " + content);
        }
    }

    private void addDocuments(SolrDao<Item> solrDao) {
        Collection<SolrInputDocument> docs = new ArrayList<SolrInputDocument>();
        for (int i = 0; i < 1000; i++)
            docs.add(getRandomSolrDoc(i));

        solrDao.putDoc(docs);
    }

    private SolrInputDocument getRandomSolrDoc(int count) {
        SolrInputDocument doc = new SolrInputDocument();
        doc.addField("id", "id" + count, 1.0f);
        doc.addField("name", "doc" + count, 1.0f);
        doc.addField("price", count % 10);
        return doc;
    }
}
