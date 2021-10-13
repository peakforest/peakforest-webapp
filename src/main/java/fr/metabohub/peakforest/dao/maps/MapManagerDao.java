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

	public static Long create(//
			final MapManager mapManager)//
			throws HibernateException {
		Transaction transaction = null;
		Long id = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			id = create(session, mapManager);
			transaction.commit();
		} catch (final HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		}
		return id;
	}

	public static Long create(//
			final Session session, //
			final MapManager mapManager)//
			throws HibernateException {
		mapManager.setCreated(new Date());
		mapManager.setUpdated(new Date());
		return (Long) session.save(mapManager);
	}

	public static MapManager read(final Short mapSource) throws HibernateException {
		Transaction transaction = null;
		MapManager mapManager = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			mapManager = read(session, mapSource);
			mapManager.countEntities();
			transaction.commit();
		} catch (final HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		}
		return mapManager;
	}

	public static MapManager read(//
			final Session session, //
			final Short mapSource)//
			throws HibernateException {
		final String queryString = "from " + MapManager.class.getSimpleName() + " where map_source =:source";
		final MapManager mapManager = (MapManager) session.createQuery(queryString).setParameter("source", mapSource)
				.uniqueResult();
		mapManager.countEntities();
		return mapManager;
	}

	public static boolean exists(//
			final Session session, //
			final Short mapSource)//
			throws HibernateException {
		final String hqlQuery = "select count(*) from " + MapManager.class.getSimpleName()
				+ " where map_source =:source";
		final TypedQuery<Long> query = session.createQuery(hqlQuery, Long.class);
		query.setParameter("source", mapSource);
		final Object queryResult = query.getSingleResult();
		return queryResult != null && ((Long) queryResult).intValue() == 1;
	}

	public static boolean exists(//
			final Short mapSource)//
			throws HibernateException {
		boolean exists = Boolean.FALSE;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			exists = MapManagerDao.exists(session, mapSource);
		} catch (final Exception e) {
			e.printStackTrace();
		}
		return exists;
	}

	public static List<MapManager> readAll() {
		List<MapManager> mapManagers = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			mapManagers = MapManagerDao.readAll(session);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return mapManagers;
	}

	public static List<MapManager> readAll(final Session session) {
		return session.createQuery("from " + MapManager.class.getSimpleName(), MapManager.class).list();
	}

	public static void delete(final Session session, final Short mapSource) throws HibernateException {
		final MapManager mapManager = read(session, mapSource);
		session.delete(mapManager);
	}

	public static void delete(final Short mapSource) throws HibernateException {
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