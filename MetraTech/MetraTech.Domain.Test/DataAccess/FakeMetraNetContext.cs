using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Notifications;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data.Entity;
using System.Linq;

namespace MetraTech.Domain.Test.DataAccess
{
  /// <summary>
  /// Provides im-memory database context for unit tests
  /// </summary>
  public class FakeMetraNetContext : IMetraNetContext
  {
    public IDbSet<Entity> Entities { get; set; }
    public IDbSet<NotificationConfiguration> NotificationConfigurations { get; set; }
    public IDbSet<NotificationEndpoint> NotificationEndpoints { get; set; }

    public IDbSet<TEntity> Set<TEntity>() where TEntity : class
    {
      var tables = typeof (FakeMetraNetContext).GetProperties().Where(property => property.PropertyType == typeof (IDbSet<TEntity>));
      foreach (var property in tables)
        return property.GetValue(this, null) as IDbSet<TEntity>;
      throw new InvalidOperationException("Type collection not found");
    }

  }

  internal class FakeDbSet<T> : IDbSet<T> where T : class 
  {
    readonly ObservableCollection<T> _data;
    readonly IQueryable _query;

    public FakeDbSet()
    {
      _data = new ObservableCollection<T>();
      _query = _data.AsQueryable();
    }

    public virtual T Find(params object[] keyValues)
    {
      var firstValue = this.FirstOrDefault();
      var entity = firstValue as Entity;
      if (entity != null)
        return this.Cast<Entity>().SingleOrDefault(d => d.EntityId == (Guid)keyValues.Single()) as T;

      return null;
    }

    public T Add(T item)
    {
      _data.Add(item);
      return item;
    }

    public T Remove(T item)
    {
      _data.Remove(item);
      return item;
    }

    public T Attach(T item)
    {
      _data.Add(item);
      return item;
    }

    public T Detach(T item)
    {
      _data.Remove(item);
      return item;
    }

    public T Create()
    {
      return Activator.CreateInstance<T>();
    }

    public TDerivedEntity Create<TDerivedEntity>() where TDerivedEntity : class, T
    {
      return Activator.CreateInstance<TDerivedEntity>();
    }

    public ObservableCollection<T> Local
    {
      get { return _data; }
    }

    Type IQueryable.ElementType
    {
      get { return _query.ElementType; }
    }

    System.Linq.Expressions.Expression IQueryable.Expression
    {
      get { return _query.Expression; }
    }

    IQueryProvider IQueryable.Provider
    {
      get { return _query.Provider; }
    }

    System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
    {
      return _data.GetEnumerator();
    }

    IEnumerator<T> IEnumerable<T>.GetEnumerator()
    {
      return _data.GetEnumerator();
    }

    public FakeDbSet(IEnumerable<T> entityCollection)
    {
      _data = new ObservableCollection<T>(entityCollection);
      _query = _data.AsQueryable();
    }
  }

  /// <summary>
  /// Helper class with useful extenders
  /// </summary>
  public static class EnumerableExtender
  {
    /// <summary>
    /// converting of object collection to FakeDbSet of objects. Used for DataContext mocking
    /// </summary>
    /// <typeparam name="T">type of objects</typeparam>
    /// <param name="list">collection of objects</param>
    /// <returns>ShimTable of objects</returns>
    public static IDbSet<T> ToIDbSet<T>(this IEnumerable<T> list) where T : class
    {
      return new FakeDbSet<T>(list);
    }
  }
}
