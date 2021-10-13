/**
 * 
 */
package fr.metabohub.peakforest.dao.maps;

import java.util.Date;
import java.util.List;

import javax.persistence.TypedQuery;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;

import fr.metabohub.peakforest.model.maps.MapManager;
import fr.metabohub.peakforest.utils.PeakForestApiHibernateUtils;

public class MapManagerDao {

	public static Long create(MapManager mapManager) throws HibernateException {
		Transaction transaction = null;
		Long id = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			id = create(session, mapManager);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		}
		return id;
	}

	public static Long create(Session session, MapManager mapManager) throws HibernateException {
		Long id;
		mapManager.setCreated(new Date());
		mapManager.setUpdated(new Date());
		id = (Long) session.save(mapManager);
		return id;
	}

	public static MapManager read(Short mapSource) throws HibernateException {
		Transaction transaction = null;
		MapManager mapManager = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			mapManager = read(session, mapSource);
			mapManager.getMapEntities().size();
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		}
		return mapManager;
	}

	public static MapManager read(Session session, Short mapSource) throws HibernateException {
		String queryString = "from " + MapManager.class.getSimpleName() + " where map_source =:source";
		MapManager mapManager = (MapManager) session.createQuery(queryString).setParameter("source", mapSource)
				.uniqueResult();
		mapManager.getMapEntities().size();
		return mapManager;
	}

	public static boolean exists(Session session, Short mapSource) throws HibernateException {
		boolean exists = false;
		String hqlQuery = "select count(*) from " + MapManager.class.getSimpleName() + " where map_source =:source";
		TypedQuery<Long> query = session.createQuery(hqlQuery, Long.class);
		query.setParameter("source", mapSource);
		Object queryResult = query.getSingleResult();
		exists = queryResult != null && ((Long) queryResult).intValue() == 1;
		return exists;

	}

	public static boolean exists(Short mapSource) throws HibernateException {
		Transaction transaction = null;
		boolean exists = false;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			exists = MapManagerDao.exists(session, mapSource);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		}
		return exists;
	}

	public static List<MapManager> readAll() {
		Transaction transaction = null;
		List<MapManager> mapManagers = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			mapManagers = MapManagerDao.readAll(session);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		}
		return mapManagers;
	}

	public static List<MapManager> readAll(Session session) {
		return session.createQuery("from " + MapManager.class.getSimpleName(), MapManager.class).list();
	}

	public static void delete(Session session, Short mapSource) throws HibernateException {
		MapManager mapManager = read(session, mapSource);
		session.delete(mapManager);
	}

	public static void delete(Short mapSource) throws HibernateException {
		Transaction transaction = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			delete(session, mapSource);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		}
	}

}